import Foundation
import CoreData
import SwiftUI

class TaskListViewModel: ObservableObject {
    @Published var tasks: [TaskEntity] = []
    @Published var filteredTasks: [TaskEntity] = []
    @Published var searchText: String = "" {
        didSet {
            updateSearchResults() // Обновляем результаты поиска при изменении текста
        }
    }

    private let context: NSManagedObjectContext
    private let backgroundContext: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        self.backgroundContext = PersistenceController.shared.backgroundContext
        loadTasks()

        if isFirstLaunch() {
            loadTasksFromAPI()
        }
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
            updateSearchResults() // Обновляем результаты поиска после загрузки задач
        } catch {
            print("Ошибка загрузки задач из Core Data: \(error.localizedDescription)")
        }
    }

    // Загрузка задач из API
    func loadTasksFromAPI() {
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            print("Неверный URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Ошибка сети: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("Нет данных от API")
                return
            }

            do {
                let todoResponse = try JSONDecoder().decode(TodoResponse.self, from: data)
                DispatchQueue.main.async {
                    self.saveTasksFromAPI(todos: todoResponse.todos)
                    // Устанавливает флаг только после успешного сохранения данных
                    UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
                }
            } catch {
                print("Ошибка декодирования: \(error.localizedDescription)")
            }
        }.resume()
    }

    // Сохранение задач из API в CoreData
    private func saveTasksFromAPI(todos: [Task]) {
        backgroundContext.perform {
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
                DispatchQueue.main.async {
                    self.loadTasks() // Обновление списка задач на главном потоке
                }
            } catch {
                print("Ошибка сохранения задач в CoreData: \(error.localizedDescription)")
            }
        }
    }

    // Добавление задачи
    func addTask(title: String, description: String, date: String) {
        backgroundContext.perform {
            let newTask = TaskEntity(context: self.backgroundContext)
            newTask.id = Int64(Date().timeIntervalSince1970)
            newTask.title = title
            newTask.descriptionText = description
            newTask.date = date
            newTask.isCompleted = false

            do {
                try self.backgroundContext.save()
                DispatchQueue.main.async {
                    withAnimation {
                        self.tasks.append(newTask)
                        self.updateSearchResults() // Обновляем результаты поиска
                    }
                }
            } catch {
                print("Ошибка при сохранении задачи: \(error.localizedDescription)")
            }
        }
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
        backgroundContext.perform {
            let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d", task.id)

            do {
                if let taskInBackgroundContext = try self.backgroundContext.fetch(request).first {
                    taskInBackgroundContext.isCompleted.toggle()
                    try self.backgroundContext.save()

                    DispatchQueue.main.async {
                        self.loadTasks() // Обновление списка задач на главном потоке
                    }
                }
            } catch {
                print("Ошибка при обновлении задачи: \(error.localizedDescription)")
            }
        }
    }

    // Удаление задачи
    func deleteTask(at offsets: IndexSet) {
        backgroundContext.perform {
            // ID задачи, которую нужно удалить
            let taskIDs = offsets.map { self.tasks[$0].id }

            let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id IN %@", taskIDs)

            do {
                let tasksToDelete = try self.backgroundContext.fetch(request)
                for task in tasksToDelete {
                    self.backgroundContext.delete(task)
                }

                try self.backgroundContext.save()

                DispatchQueue.main.async {
                    withAnimation {
                        self.tasks.remove(atOffsets: offsets)
                        self.updateSearchResults() // Обновляем результаты поиска
                    }
                }
            } catch {
                print("Ошибка при удалении задачи: \(error.localizedDescription)")
            }
        }
    }

    // Обновление задачи
    func updateTask(task: TaskEntity, newTitle: String, newDescription: String, newDate: Date) {
        backgroundContext.perform {
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

                    DispatchQueue.main.async {
                        self.loadTasks() // Обновление списка задач на главном потоке
                    }
                }
            } catch {
                print("Ошибка при обновлении задачи: \(error.localizedDescription)")
            }
        }
    }
}
