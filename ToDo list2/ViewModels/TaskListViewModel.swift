import Foundation
import CoreData
import SwiftUI

class TaskListViewModel: ObservableObject {
    @Published var tasks: [TaskEntity] = []
    private let context: NSManagedObjectContext
    @Published var searchText: String = ""

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        loadTasks()

        if isFirstLaunch() {
            loadTasksFromAPI()
        }
    }
    
    private func isFirstLaunch() -> Bool {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        if !hasLaunchedBefore {
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            return true
        }
        return false
    }
    
    func loadTasks() {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            tasks = try context.fetch(request)
        } catch {
            print("Ошибка загрузки задач из Core Data: \(error.localizedDescription)")
        }
    }
    
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
            loadTasks()
        } catch {
            print("Ошибка сохранения задач в CoreData: \(error.localizedDescription)")
        }
    }
    
    func addTask(title: String, description: String, date: String) {
        let newTask = TaskEntity(context: context)
        newTask.id = Int64(Date().timeIntervalSince1970)
        newTask.title = title
        newTask.descriptionText = description
        newTask.date = date
        newTask.isCompleted = false

        do {
            try context.save()
            withAnimation {
                tasks.append(newTask)
            }
        } catch {
            print("Ошибка при сохранении задачи: \(error.localizedDescription)")
        }
    }
    
    var filteredTasks: [TaskEntity] {
            if searchText.isEmpty {
                return tasks
            } else {
                return tasks.filter { $0.title?.localizedCaseInsensitiveContains(searchText) == true }
            }
        }
    
    func toggleCompletion(for task: TaskEntity) {
        task.isCompleted.toggle()
        do {
            try context.save()
            loadTasks() // Добавлено для обновления списка после изменения статуса
        } catch {
            print("Ошибка при обновлении задачи: \(error.localizedDescription)")
        }
    }
    
    func deleteTask(at offsets: IndexSet) {
        offsets.forEach { index in
            let task = tasks[index]
            context.delete(task)
        }
        withAnimation {
            tasks.remove(atOffsets: offsets)
        }
        do {
            try context.save()
        } catch {
            print("Ошибка при удалении задачи: \(error.localizedDescription)")
        }
    }
    
    func updateTask(task: TaskEntity, newTitle: String, newDescription: String, newDate: Date) {
        task.title = newTitle
        task.descriptionText = newDescription
        task.date = DateFormatter.localizedString(from: newDate, dateStyle: .short, timeStyle: .short)
        
        do {
            try context.save()
            loadTasks()
        } catch {
            print("Ошибка при обновлении задачи: \(error.localizedDescription)")
        }
    }
}
