import SwiftUI

struct EditTaskView: View {
    @ObservedObject var viewModel: TaskListViewModel
    @Environment(\.presentationMode) var presentationMode
    var task: TaskEntity
    
    @State private var editedTitle: String
    @State private var editedDescription: String
    @State private var editedDate: Date
    
    init(viewModel: TaskListViewModel, task: TaskEntity) {
        self.viewModel = viewModel
        self.task = task
        _editedTitle = State(initialValue: task.title ?? "")
        _editedDescription = State(initialValue: task.descriptionText ?? "")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        if let dateString = task.date, let date = dateFormatter.date(from: dateString) {
            _editedDate = State(initialValue: date)
        } else {
            _editedDate = State(initialValue: Date())
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Редактировать задачу")) {
                    TextField("Название задачи", text: $editedTitle)
                        .onChange(of: editedTitle) { oldValue, newValue in
                            if newValue.count > 100 {
                                editedTitle = String(newValue.prefix(100))
                            }
                        }
                        .keyboardType(.default)
                    
                    TextField("Описание задачи", text: Binding(
                        get: { editedDescription.isEmpty ? "" : editedDescription },
                        set: { editedDescription = $0 }
                    ))
                    .onChange(of: editedDescription) { oldValue, newValue in
                        if newValue.count > 900 {
                            editedDescription = String(newValue.prefix(900))
                        }
                    }
                    .keyboardType(.default)
                    
                    // Обернули DatePicker в VStack и добавили ignoresSafeArea
                    VStack {
                        DatePicker("Дата", selection: $editedDate, displayedComponents: .date)
                            .environment(\.locale, Locale(identifier: "ru_RU"))
                    }
                    .ignoresSafeArea(.keyboard) // Игнорируем клавиатуру
                }
            }
            .navigationTitle("Редактировать задачу")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                        viewModel.updateTask(
                            task: task,
                            newTitle: editedTitle,
                            newDescription: editedDescription,
                            newDate: editedDate
                        )
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(editedTitle.isEmpty)
                }
            }
        }
        .ignoresSafeArea(.keyboard) // Дополнительно игнорируем клавиатуру для всего NavigationStack
    }
}
