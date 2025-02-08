import Foundation
import Combine

class TaskListViewModel: ObservableObject {
    @Published var tasks: [Task] = []
    
    init() {
        loadTasks()
    }
    
    func loadTasks() {
        guard let url = URL(string: "https://dummyjson.com/todos") else {
            print("❌ Неверный URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Ошибка сети: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("❌ Нет данных от API")
                return
            }
            
            do {
                let todoResponse = try JSONDecoder().decode(TodoResponse.self, from: data)
                DispatchQueue.main.async {
                    self.tasks = todoResponse.todos
                }
            } catch {
                print("❌ Ошибка декодирования: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func addTask(_ task: Task) {
        tasks.append(task)
    }
    
    func toggleCompletion(for task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
        }
    }
}
