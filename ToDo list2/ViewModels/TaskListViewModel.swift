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
    private var cancellables = Set<AnyCancellable>() // Для хранения подписок

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        self.backgroundContext = PersistenceController.shared.backgroundContext
        loadTasks()

        if isFirstLaunch() {
            loadTasksFromAPI()
        }

        // Подписка на изменения searchText
        $searchText
            .debounce(for: .seconds(0.3), scheduler: RunLoop.main) // Задержка для уменьшения количества обновлений
            .sink { [weak self] _ in
                self?.updateSearchResults()
            }
            .store(in: &cancellables)
    }

    deinit {
        cancellables.forEach { $0.cancel() } // Отмена всех подписок при деинициализации
    }

    // Проверка первого запуска
    private func isFirstLaunch() -> Bool {
        return !UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
    }

    // Загрузка задач из CoreData
    func loadTasks() {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [sortDescriptor]

        do {
            tasks = try context.fetch(request)
            updateSearchResults()
        } catch {
            print("Ошибка загрузки задач из Core Data: \(error.localizedDescription)")
        }
    }

    // Загрузка задач из API с использованием Combine
    func loadTasksFromAPI() {
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            print("Неверный URL")
            return
        }

        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data) // Извлекаем данные из ответа
            .decode(type: TodoResponse.self, decoder: JSONDecoder()) // Декодируем JSON
            .receive(on: DispatchQueue.main) // Переключаемся на главный поток
            .catch { error -> Just<TodoResponse> in
                print("Ошибка сети: \(error.localizedDescription)")
                return Just(TodoResponse(todos: [])) // Возвращаем пустой ответ в случае ошибки
            }
            .sink { [weak self] todoResponse in
                self?.saveTasksFromAPI(todos: todoResponse.todos)
                    .sink { completion in
                        if case .failure(let error) = completion {
                            print("Ошибка сохранения задач в CoreData: \(error.localizedDescription)")
                        }
                    } receiveValue: {
                        UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
                        self?.loadTasks()
                    }
                    .store(in: &self!.cancellables)
            }
            .store(in: &cancellables) // Сохраняем подписку
    }

    // Сохранение задач из API в CoreData с использованием Future
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

    // Добавление задачи с использованием Future
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
        .sink { completion in
            if case .failure(let error) = completion {
                print("Ошибка при сохранении задачи: \(error.localizedDescription)")
            }
        } receiveValue: { [weak self] _ in
            self?.loadTasks() // Перезагружаем задачи после добавления
        }
        .store(in: &cancellables)
    }

    // Обновление результатов поиска
    private func updateSearchResults() {
        if searchText.isEmpty {
            filteredTasks = tasks
        } else {
            filteredTasks = tasks.filter { task in
                task.title?.localizedCaseInsensitiveContains(searchText) == true
            }
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
        .sink { completion in
            if case .failure(let error) = completion {
                print("Ошибка при обновлении задачи: \(error.localizedDescription)")
            }
        } receiveValue: { [weak self] _ in
            self?.loadTasks()
        }
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
        .sink { completion in
            if case .failure(let error) = completion {
                print("Ошибка при удалении задачи: \(error.localizedDescription)")
            }
        } receiveValue: { [weak self] _ in
            withAnimation {
                self?.tasks.remove(atOffsets: offsets)
                self?.updateSearchResults()
            }
        }
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
        .sink { completion in
            if case .failure(let error) = completion {
                print("Ошибка при обновлении задачи: \(error.localizedDescription)")
            }
        } receiveValue: { [weak self] _ in
            self?.loadTasks()
        }
        .store(in: &cancellables)
    }
}
