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
                Section(header: Text("Редактировать задачу")
                    .foregroundColor(.white)
                    .font(.headline)
                ) {
                    // Поле для редактирования названия задачи
                    TextField("Название задачи", text: $editedTitle)
                        .foregroundColor(.white)
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 39 / 255, green: 39 / 255, blue: 41 / 255))
                        .cornerRadius(8)
                        .onReceive(editedTitle.publisher.collect()) { value in
                            if value.count > 100 {
                                editedTitle = String(value.prefix(100))
                            }
                        }

                    // Поле для редактирования описания задачи
                    TextField("Описание задачи", text: Binding(
                        get: { editedDescription.isEmpty ? "" : editedDescription },
                        set: { newValue in
                            if newValue.count <= 900 {
                                editedDescription = newValue
                            }
                        }
                    ), prompt: Text("Описание задачи").foregroundColor(.white.opacity(0.5)))
                    .foregroundColor(.white)
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 39 / 255, green: 39 / 255, blue: 41 / 255))
                    .cornerRadius(8)

                    // Поле для выбора даты
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ДАТА")
                            .foregroundColor(.white)
                            .font(.headline)

                        DatePicker("", selection: $editedDate, displayedComponents: .date)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .padding(10)
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 39 / 255, green: 39 / 255, blue: 41 / 255))
                            .cornerRadius(8)
                            .colorScheme(.dark)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .listRowBackground(Color.black)
            }
            .scrollContentBackground(.hidden)
            .background(Color.black)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
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
                    .foregroundColor(.white)
                }
            }
            .tint(.white)
            .ignoresSafeArea(.keyboard)
        }
    }
}

