import CoreData
import Combine

class TaskCoreDataManager: ObservableObject {
    static let shared = TaskCoreDataManager()
    
    let context: NSManagedObjectContext
    let backgroundContext: NSManagedObjectContext
    
    @Published var tasks: [Task] = [] // Автоматическое обновление списка задач
    private var cancellables = Set<AnyCancellable>()

    private init() {
        context = PersistenceController.shared.container.viewContext
        backgroundContext = PersistenceController.shared.backgroundContext
        
        // Подписка на изменения Core Data
        observeCoreDataChanges()
        fetchTasks()
    }

    // MARK: - Подписка на изменения Core Data
    private func observeCoreDataChanges() {
        NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange, object: context)
            .sink { [weak self] _ in
                self?.fetchTasks()
            }
            .store(in: &cancellables)
    }

    // MARK: - Сохранение задачи
    func saveTask(id: Int, title: String, description: String?, date: String, isCompleted: Bool) {
        backgroundContext.perform {
            let taskEntity = TaskEntity(context: self.backgroundContext)
            taskEntity.id = Int64(id)
            taskEntity.title = title
            taskEntity.descriptionText = description
            taskEntity.date = date
            taskEntity.isCompleted = isCompleted

            do {
                try self.backgroundContext.save()
            } catch {
                print("Ошибка сохранения задачи: \(error)")
            }
        }
    }

    // MARK: - Загрузка всех задач
    func fetchTasks() {
        context.perform {
            let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
            request.sortDescriptors = [sortDescriptor]

            do {
                let entities = try self.context.fetch(request)
                DispatchQueue.main.async {
                    self.tasks = entities.map { Task(id: Int($0.id), title: $0.title ?? "", descriptionText: $0.descriptionText, date: $0.date ?? "", isCompleted: $0.isCompleted) }
                }
            } catch {
                print("Ошибка загрузки задач: \(error)")
            }
        }
    }

    // MARK: - Асинхронная загрузка с Combine
    func fetchTasksPublisher() -> AnyPublisher<[Task], Never> {
        Future { promise in
            self.context.perform {
                let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
                let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
                request.sortDescriptors = [sortDescriptor]

                do {
                    let entities = try self.context.fetch(request)
                    let tasks = entities.map { Task(id: Int($0.id), title: $0.title ?? "", descriptionText: $0.descriptionText, date: $0.date ?? "", isCompleted: $0.isCompleted) }
                    promise(.success(tasks))
                } catch {
                    print("Ошибка загрузки задач: \(error)")
                    promise(.success([]))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }

    // MARK: - Удаление задачи
    func deleteTask(id: Int) {
        backgroundContext.perform {
            let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d", id)

            do {
                if let entity = try self.backgroundContext.fetch(request).first {
                    self.backgroundContext.delete(entity)
                    try self.backgroundContext.save()
                }
            } catch {
                print("Ошибка удаления задачи: \(error)")
            }
        }
    }

    // MARK: - Обновление задачи
    func updateTask(task: TaskEntity, newTitle: String, newDescription: String, newDate: Date) {
        backgroundContext.perform {
            task.title = newTitle
            task.descriptionText = newDescription
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yy"
            task.date = dateFormatter.string(from: newDate)

            do {
                try self.backgroundContext.save()
            } catch {
                print("Ошибка обновления задачи: \(error)")
            }
        }
    }
}

