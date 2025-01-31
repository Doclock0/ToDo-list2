import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TaskListViewModel()
    @State private var newTaskTitle = ""
    @State private var showAddTaskView = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Поиск
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .padding(.leading, 10)
                    TextField("Search", text: $newTaskTitle)
                    Image(systemName: "mic.fill")
                        .foregroundColor(.gray)
                        .padding(.trailing, 10)
                }
                .frame(width: 360, height: 36)
                .background(Color(red: 39 / 255, green: 39 / 255, blue: 41 / 255))
                .cornerRadius(8)
                .padding(.top, 16)
                .padding(.leading, 6)
                
                // Список задач
                List {
                    ForEach(viewModel.tasks) { task in
                        VStack {
                            HStack(alignment: .top) {
                                ZStack {
                                    Circle()
                                        .stroke(task.isCompleted ? Color(red: 254 / 255, green: 215 / 255, blue: 2 / 255) : Color(red: 77 / 255, green: 85 / 255, blue: 94 / 255), lineWidth: 1.5)
                                        .frame(width: 24, height: 24)
                                    
                                    if task.isCompleted {
                                        Image(systemName: "checkmark")
                                            .resizable()
                                            .frame(width: 12, height: 9)
                                            .foregroundColor(Color(red: 254 / 255, green: 215 / 255, blue: 2 / 255))
                                    }
                                }
                                
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
                            .onTapGesture {
                                viewModel.toggleCompletion(for: task)
                            }
                            
                            Spacer(minLength: 0)
                            // Кастомный разделитель
                            Rectangle()
                                .fill(Color(red: 77 / 255, green: 85 / 255, blue: 94 / 255))
                                .frame(height: 1)
                                .padding(.horizontal, 0)
                                .padding(.vertical, 0)
                        }
                        .listRowBackground(Color.black)
                        .padding(.vertical, 4)
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
                                .foregroundColor(Color(red: 254 / 255, green: 215 / 255, blue: 2 / 255))
                        }
                    }
                    .padding(.trailing, 22) // Добавляет отступ от правого края
                }
                .frame(height: 49)
                .background(Color(red: 39 / 255, green: 39 / 255, blue: 41 / 255))
                .sheet(isPresented: $showAddTaskView) {
                    AddTaskView(tasks: $viewModel.tasks)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Задачи")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .font(.system(size: 34, weight: .bold))
                        .padding(.top, 3)
                        .padding(.leading, 20)
                        .padding(.bottom, 8)
                }
            }
            .background(Color.black)
                        }
                    }
                }

struct AddTaskView: View {
    @Binding var tasks: [Task]
    @Environment(\.presentationMode) var presentationMode
    @State private var newTaskTitle = ""
    @State private var newTaskDescription = ""
    @State private var newTaskDate = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Новая задача")) {
                    TextField("Название задачи", text: $newTaskTitle)
                    TextField("Описание задачи", text: $newTaskDescription)
                    DatePicker("Дата", selection: $newTaskDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Добавить задачу")
            .navigationBarItems(trailing: Button("Сохранить") {
                let newTask = Task(
                    title: newTaskTitle,
                    description: newTaskDescription,
                    date: "\(newTaskDate)",
                    isCompleted: false
                )
                tasks.append(newTask)
                presentationMode.wrappedValue.dismiss()
            })
            
            .background(Color.black)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
