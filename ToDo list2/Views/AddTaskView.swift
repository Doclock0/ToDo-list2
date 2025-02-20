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
                Section(header: Text("Новая задача")
                    .foregroundColor(.white)
                    .font(.headline)
                ) {
                    // Поле для названия задачи
                    TextField("Название задачи", text: $newTaskTitle, prompt: Text("Название задачи").foregroundColor(.white.opacity(0.5)))
                        .foregroundColor(.white)
                        .padding(10)
                        .frame(maxWidth: .infinity) // Делаем ширину на всю доступную область
                        .background(Color(red: 39 / 255, green: 39 / 255, blue: 41 / 255))
                        .cornerRadius(8)
                        .onChange(of: newTaskTitle) { oldValue, newValue in
                            if newValue.count > 100 {
                                newTaskTitle = String(newValue.prefix(100)) // Ограничение до 100 символов
                            }
                        }

                    // Поле для описания задачи
                    TextField("Описание задачи", text: $newTaskDescription, prompt: Text("Описание задачи").foregroundColor(.white.opacity(0.5)))
                        .foregroundColor(.white)
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 39 / 255, green: 39 / 255, blue: 41 / 255))
                        .cornerRadius(8)
                        .onChange(of: newTaskDescription) { oldValue, newValue in
                            if newValue.count > 900 {
                                newTaskDescription = String(newValue.prefix(900)) // Ограничение до 900 символов
                            }
                        }

                    // Поле для выбора даты
                    VStack(alignment: .leading, spacing: 8) {
                        Text("ДАТА")
                            .foregroundColor(.white)
                            .font(.headline)
                        
                        DatePicker("", selection: $newTaskDate, displayedComponents: .date)
                            .datePickerStyle(.wheel)
                            .labelsHidden()
                            .padding(10)
                            .frame(maxWidth: .infinity) // Растягиваем по ширине
                            .background(Color(red: 39 / 255, green: 39 / 255, blue: 41 / 255))
                            .cornerRadius(8)
                            .colorScheme(.dark)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading) // Выровняем по левому краю
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
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd/MM/yy"
                        let formattedDate = dateFormatter.string(from: newTaskDate)
                        
                        viewModel.addTask(
                            title: newTaskTitle,
                            description: newTaskDescription.isEmpty ? "" : newTaskDescription,
                            date: formattedDate
                        )
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(newTaskTitle.isEmpty)
                    .foregroundColor(.white)
                }
            }
            .tint(.white)
            .ignoresSafeArea(.keyboard)
        }
    }
}

