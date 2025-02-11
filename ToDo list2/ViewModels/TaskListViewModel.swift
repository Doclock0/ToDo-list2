import Foundation
import CoreData

class TaskListViewModel: ObservableObject {
    private var nextId: Int = 1
    @Published var tasks: [TaskEntity] = []
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        loadTasks()

        if isFirstLaunch() {
            loadTasksFromAPI()
        }
    }
    
    // Проверка первого запуска
    private func isFirstLaunch() -> Bool {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        if !hasLaunchedBefore {
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            return true
        }
        return false
    }
    
    // Загрузка задач из CoreData
    func loadTasks() {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        
        // Добавляем сортировку по id по возрастанию
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            tasks = try context.fetch(request)
        } catch {
            print("Ошибка загрузки задач из Core Data: \(error.localizedDescription)")
        }
    }
    
    // Загрузка задач из API только при первом запуске
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
                }
            } catch {
                print("Ошибка декодирования: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    // Сохранение загруженных задач в CoreData
    private func saveTasksFromAPI(todos: [Task]) {
        for todo in todos {
            let newTask = TaskEntity(context: context)
            newTask.id = Int64(todo.id)
            newTask.title = todo.title
            newTask.descriptionText = todo.descriptionText
            newTask.date = todo.date
            newTask.isCompleted = todo.isCompleted
        }
        
        do {
            try context.save()
            loadTasks() // Обновляем список задач после сохранения
        } catch {
            print("Ошибка сохранения задач в CoreData: \(error.localizedDescription)")
        }
    }
    
    // Добавление новой задачи
    func addTask(title: String, description: String, date: String) {
        let newTask = TaskEntity(context: context)
        newTask.id = Int64(Date().timeIntervalSince1970)
        newTask.title = title
        newTask.descriptionText = description
        newTask.date = date
        newTask.isCompleted = false

        do {
            try context.save()
            loadTasks()
        } catch {
            print("Ошибка при сохранении задачи: \(error.localizedDescription)")
        }
    }
    
    // Переключение статуса выполнения задачи
    func toggleCompletion(for task: TaskEntity) {
        task.isCompleted.toggle()
        do {
            try context.save()
            loadTasks()
        } catch {
            print("Ошибка при обновлении задачи: \(error.localizedDescription)")
        }
    }
    
    // Удаление задачи
    func deleteTask(at offsets: IndexSet) {
        offsets.forEach { index in
            let task = tasks[index]
            context.delete(task)
        }
        do {
            try context.save()
            loadTasks()
        } catch {
            print("Ошибка при удалении задачи: \(error.localizedDescription)")
        }
    }
    
    func updateTask(task: TaskEntity, newTitle: String, newDescription: String, newDate: Date) {
        TaskCoreDataManager.shared.updateTask(
            task: task,
            newTitle: newTitle,
            newDescription: newDescription,
            newDate: newDate
        )
        loadTasks() // Обновляем данные для UI
    }
    
}
