import Foundation
import CoreData
import SwiftUI
import Combine

class TaskListViewModel: ObservableObject {
    @Published var tasks: [TaskEntity] = []
    @Published var filteredTasks: [TaskEntity] = []
    @Published var searchText: String = "" {
        didSet {
            updateSearchResults()
        }
    }
    
    private let context: NSManagedObjectContext
    private let backgroundContext: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        self.backgroundContext = PersistenceController.shared.backgroundContext
        loadTasks()

        if isFirstLaunch() {
            fetchTasksFromAPI()
        }

        $searchText
            .debounce(for: .seconds(0.3), scheduler: RunLoop.main)
            .sink { [weak self] _ in self?.updateSearchResults() }
            .store(in: &cancellables)
    }

    deinit {
        cancellables.forEach { $0.cancel() }
    }

    private func isFirstLaunch() -> Bool {
        return !UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
    }

    // Загрузка задач из CoreData
    func loadTasks() {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        backgroundContext.perform { [weak self] in
            do {
                let fetchedTasks = try self?.backgroundContext.fetch(request) ?? []
                DispatchQueue.main.async {
                    self?.tasks = fetchedTasks
                    self?.updateSearchResults()
                }
            } catch {
                print("Ошибка загрузки задач из Core Data: \(error.localizedDescription)")
            }
        }
    }

    // Получение данных из API и сохранение их в CoreData
    func fetchTasksFromAPI() {
        NetworkManager.shared.loadTasksFromAPI()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Ошибка сети: \(error.localizedDescription)")
                }
            }, receiveValue: { [weak self] todos in
                self?.saveTasksFromAPI(todos: todos)
                    .sink(receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            print("Ошибка сохранения задач в CoreData: \(error.localizedDescription)")
                        }
                    }, receiveValue: {
                        UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
                        self?.loadTasks()
                    })
                    .store(in: &self!.cancellables)
            })
            .store(in: &cancellables)
    }

    // Сохранение задач из API в CoreData
    private func saveTasksFromAPI(todos: [Task]) -> Future<Void, Error> {
        return Future { promise in
            self.backgroundContext.perform {
                for todo in todos {
                    let newTask = TaskEntity(context: self.backgroundContext)
                    newTask.id = Int64(todo.id)
                    newTask.title = todo.title
                    newTask.descriptionText = todo.descriptionText
                    newTask.date = todo.date
                    newTask.isCompleted = todo.isCompleted
                }
                do {
                    try self.backgroundContext.save()
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
    }

    // Добавление задачи
    func addTask(title: String, description: String, date: String) {
        Future<Void, Error> { promise in
            self.backgroundContext.perform {
                let newTask = TaskEntity(context: self.backgroundContext)
                newTask.id = Int64(Date().timeIntervalSince1970)
                newTask.title = title
                newTask.descriptionText = description
                newTask.date = date
                newTask.isCompleted = false
                do {
                    try self.backgroundContext.save()
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { completion in
            if case .failure(let error) = completion {
                print("Ошибка при сохранении задачи: \(error.localizedDescription)")
            }
        }, receiveValue: { [weak self] _ in
            self?.loadTasks()
        })
        .store(in: &cancellables)
    }

    // Обновление списка задач по поисковому запросу
    private func updateSearchResults() {
        if searchText.isEmpty {
            filteredTasks = tasks
        } else {
            filteredTasks = tasks.filter { $0.title?.localizedCaseInsensitiveContains(searchText) == true }
        }
    }

    // Переключение статуса выполнения задачи
    func toggleCompletion(for task: TaskEntity) {
        Future<Void, Error> { promise in
            self.backgroundContext.perform {
                let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %d", task.id)
                do {
                    if let taskInBackgroundContext = try self.backgroundContext.fetch(request).first {
                        taskInBackgroundContext.isCompleted.toggle()
                        try self.backgroundContext.save()
                        promise(.success(()))
                    }
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { completion in
            if case .failure(let error) = completion {
                print("Ошибка при обновлении задачи: \(error.localizedDescription)")
            }
        }, receiveValue: { [weak self] _ in
            self?.loadTasks()
        })
        .store(in: &cancellables)
    }

    // Удаление задачи
    func deleteTask(at offsets: IndexSet) {
        Future<Void, Error> { promise in
            self.backgroundContext.perform {
                let taskIDs = offsets.map { self.tasks[$0].id }
                let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id IN %@", taskIDs)
                do {
                    let tasksToDelete = try self.backgroundContext.fetch(request)
                    for task in tasksToDelete {
                        self.backgroundContext.delete(task)
                    }
                    try self.backgroundContext.save()
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { completion in
            if case .failure(let error) = completion {
                print("Ошибка при удалении задачи: \(error.localizedDescription)")
            }
        }, receiveValue: { [weak self] _ in
            withAnimation {
                self?.tasks.remove(atOffsets: offsets)
                self?.updateSearchResults()
            }
        })
        .store(in: &cancellables)
    }

    // Обновление задачи
    func updateTask(task: TaskEntity, newTitle: String, newDescription: String, newDate: Date) {
        Future<Void, Error> { promise in
            self.backgroundContext.perform {
                let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %d", task.id)
                do {
                    if let taskInBackgroundContext = try self.backgroundContext.fetch(request).first {
                        taskInBackgroundContext.title = newTitle
                        taskInBackgroundContext.descriptionText = newDescription
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd/MM/yy"
                        taskInBackgroundContext.date = dateFormatter.string(from: newDate)
                        try self.backgroundContext.save()
                        promise(.success(()))
                    }
                } catch {
                    promise(.failure(error))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { _ in }, receiveValue: { [weak self] _ in
            self?.loadTasks()
        })
        .store(in: &cancellables)
    }
}

