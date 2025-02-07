import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TaskListViewModel()
    @State private var newTaskTitle = ""
    @State private var showAddTaskView = false

    var body: some View {
        NavigationStack {
            VStack {
                // Поиск
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .padding(.leading, 10)
                    TextField("", text: $newTaskTitle, prompt: Text("Search")
                            .foregroundColor(Color(red: 244 / 255, green: 244 / 255, blue: 244 / 255).opacity(0.5))) // Цвет плейсхолдера
                            .foregroundColor(Color.white) // Цвет вводимого текста
                            
         
                }
                .frame(height: 36)
                .background(Color(red: 39 / 255, green: 39 / 255, blue: 41 / 255)) // Фон строки поиска
                .cornerRadius(8)
                .padding(.top, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)
                .padding(.trailing, 20)
               
                
                // Список задач
                List(viewModel.tasks) { task in
                    NavigationLink(value: task) {
                        VStack {
                            HStack(alignment: .top) {
                                ZStack {
                                    Circle()
                                        .stroke(task.isCompleted ? Color(red: 254 / 255, green: 215 / 255, blue: 2 / 255) : Color(red: 77 / 255, green: 85 / 255, blue: 94 / 255), lineWidth: 1.5)
                                        .frame(width: 24, height: 24)
                                        .onTapGesture {
                                            viewModel.toggleCompletion(for: task)
                                        }
                                    
                                    if task.isCompleted {
                                        
                                        Image(systemName: "checkmark")
                                            .resizable()
                                            .frame(width: 12, height: 9)
                                            .foregroundColor(Color(red: 254 / 255, green: 215 / 255, blue: 2 / 255)) // Цвет галочки
                                    }
                                }
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text(task.title)
                                        .font(.headline)
                                        .foregroundColor(task.isCompleted ? Color.gray : Color.white)
                                        .strikethrough(task.isCompleted)
                                    
                                    if !task.description.isEmpty {
                                        Text(task.description)
                                            .font(.subheadline)
                                            .foregroundColor(task.isCompleted ? Color.gray : Color.white)
                                            .lineLimit(2)
                                    }
                                    
                                    if !task.date.isEmpty {
                                        Text(task.date)
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            Spacer(minLength: 0)
                            Rectangle()
                                .fill(Color(red: 77 / 255, green: 85 / 255, blue: 94 / 255))
                                .frame(height: 1)
                                .padding(.horizontal, 0)
                                .padding(.vertical, 0)
                        }
                 
                       
                    }
                    .listRowBackground(Color.black)
                    .padding(.vertical, 4)
                    .contextMenu {
                        Button {
                            // Заглушка
                        } label: {
                            Label("Редактировать", systemImage: "pencil")
                        }
                        
                        Button {
                            // Заглушка
                        } label: {
                            Label("Поделиться", systemImage: "square.and.arrow.up")
                        }
                        
                        Button(role: .destructive) {
                            // Заглушка
                        } label: {
                            Label("Удалить", systemImage: "trash")
                        }
                    }
                }
                .padding(.top, 8)
                .listStyle(PlainListStyle())
                
                // Footer
                ZStack {
                    HStack {
                        Spacer()
                        Text("\(viewModel.tasks.count) Задач")
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                            
                        Spacer()
                    }
                    

                    HStack {
                        Spacer()
                        Button(action: {
                            showAddTaskView.toggle()
                        }) {
                            Image(systemName: "square.and.pencil")
                                .resizable()
                                .frame(width: 22, height: 22)
                                .foregroundColor(Color(red: 254 / 255, green: 215 / 255, blue: 2 / 255)) //
                        }
                    }
                    .padding(.trailing, 22)
                }
                .frame(height: 49)
                .background(Color(red: 39 / 255, green: 39 / 255, blue: 41 / 255)) // Фон нижней панели
                .sheet(isPresented: $showAddTaskView) {
                    AddTaskView(tasks: $viewModel.tasks)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Задачи")
                        .foregroundColor(.white) // Цвет заголовка
                        .fontWeight(.bold)
                        .font(.system(size: 34, weight: .bold))
                        .padding(.top, 3)
                        
                        .padding(.bottom, 8)
                }
            }
            .background(Color.black) // Цвет фона всего экрана
            .navigationDestination(for: Task.self) { task in
                TaskDetailView(task: task) // Навигация для TaskDetailView
            }
        }
    }
}

struct AddTaskView: View {
    @Binding var tasks: [Task]
    @Environment(\.presentationMode) var presentationMode
    @State private var newTaskTitle = "" // Обязательное поле
    @State private var newTaskDescription = ""
    @State private var newTaskDate = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Новая задача")) {
                    TextField("Название задачи", text: $newTaskTitle)
                        .onChange(of: newTaskTitle) {
                            if newTaskTitle.count > 100 {
                                newTaskTitle = String(newTaskTitle.prefix(100))
                            }
                        }
                    TextField("Описание задачи", text: $newTaskDescription)
                        .onChange(of: newTaskDescription) {
                            if newTaskDescription.count > 900 {
                                newTaskDescription = String(newTaskDescription.prefix(900))
                            }
                        }
                          
                    DatePicker("Дата", selection: $newTaskDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Добавить задачу")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Сохранить") {
                                            let dateFormatter = DateFormatter()
                                            dateFormatter.dateFormat = "dd/MM/yy" // Формат даты

                                            let formattedDate = dateFormatter.string(from: newTaskDate)
                                            
                                            let newTask = Task(
                                                title: newTaskTitle,
                                                description: newTaskDescription,
                                                date: formattedDate, // Сохраняем отформатированную дату
                                                isCompleted: false
                                            )
                                            tasks.append(newTask)
                                            presentationMode.wrappedValue.dismiss()
                                        }
                                        .disabled(newTaskTitle.isEmpty) // Блокировка, если поле пустое
                                    }
                                }
                                .background(Color.black)
                            }
                        }
                    }

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
