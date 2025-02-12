import SwiftUI

struct AddTaskView: View {
    @ObservedObject var viewModel: TaskListViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var newTaskTitle = "" // Обязательное поле
    @State private var newTaskDescription = ""
    @State private var newTaskDate = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Новая задача")) {
                    // Поле для названия задачи
                    TextField("Название задачи", text: $newTaskTitle)
                        .onChange(of: newTaskTitle) { oldValue, newValue in
                            if newValue.count > 100 {
                                newTaskTitle = String(newValue.prefix(100))
                            }
                        }
                    
                    // Поле для описания задачи
                    TextField("Описание задачи", text: $newTaskDescription)
                        .onChange(of: newTaskDescription) { oldValue, newValue in
                            if newValue.count > 900 {
                                newTaskDescription = String(newValue.prefix(900))
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
                        
                        // Передаём пустую строку, если описание не указано
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
            .ignoresSafeArea(.keyboard) // Игнорируем клавиатуру
        }
    }
}
