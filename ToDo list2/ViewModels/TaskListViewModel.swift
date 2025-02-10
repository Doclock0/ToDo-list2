import Foundation
import Combine

class TaskListViewModel: ObservableObject {
    private var nextId: Int = 1
    @Published var tasks: [Task] = []

    init() {
        loadTasks()
    }
    
    func loadTasks() {
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
                    self.tasks = todoResponse.todos
                    // уже загруженные задачи для корректного ID
                    if let maxId = self.tasks.map({ $0.id }).max() {
                        self.nextId = maxId + 1
                    }
                }
            } catch {
                print("Ошибка декодирования: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    //  метод для добавления задачи
    func addTask(title: String, description: String, date: String) {
        let newTask = Task(
            id: nextId,
            title: title,
            description: description,
            date: date,
            isCompleted: false
        )
        
        tasks.append(newTask)
        nextId += 1
    }
    
    func toggleCompletion(for task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
        }
    }
}
