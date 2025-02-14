import SwiftUI

struct AddTaskView: View {
    @ObservedObject var viewModel: TaskListViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var newTaskTitle = ""
    @State private var newTaskDescription = ""
    @State private var newTaskDate = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Новая задача")) {
                    
                    TextField("Название задачи", text: $newTaskTitle)
                        .onReceive(newTaskTitle.publisher.collect()) { value in
                            if value.count > 100 {
                                newTaskTitle = String(value.prefix(100))
                            }
                        }
                    
                  
                    TextField("Описание задачи", text: $newTaskDescription)
                        .onReceive(newTaskDescription.publisher.collect()) { value in
                            if value.count > 900 {
                                newTaskDescription = String(value.prefix(900))
                            }
                        }
                    
                    // Выбор даты
                    DatePicker("Дата", selection: $newTaskDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Добавить задачу")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd/MM/yy"
                        let formattedDate = dateFormatter.string(from: newTaskDate)
                        
                        // передаю пустую строку, если описание не указано
                        viewModel.addTask(
                            title: newTaskTitle,
                            description: newTaskDescription.isEmpty ? "" : newTaskDescription,
                            date: formattedDate
                        )
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(newTaskTitle.isEmpty)
                }
            }
            .ignoresSafeArea(.keyboard) 
        }
    }
}
