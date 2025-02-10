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
                .padding(.bottom, 8)
                .padding(.leading, 20)
                .padding(.trailing, 20)
                
                // Список задач
                List(viewModel.tasks) { task in
                    NavigationLink(value: task) {
                        VStack(spacing: 0) { // Убираем лишние отступы между элементами
                            HStack(alignment: .top, spacing: 12) { // Добавим небольшой отступ между кружком и текстом
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
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(task.title)
                                        .font(.headline)
                                        .font(.system(size: 16))
                                        .foregroundColor(task.isCompleted ? Color.gray : Color.white)
                                        .strikethrough(task.isCompleted)
                                    
                                    if let description = task.description, !description.isEmpty {
                                        Text(description)
                                            .font(.subheadline)
                                            .font(.system(size: 12))
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
                            .padding(.vertical, 12) // Одинаковый отступ сверху и снизу

                            Rectangle()
                                .fill(Color(red: 77 / 255, green: 85 / 255, blue: 94 / 255))
                                .frame(height: 0.5) // Тоньше для визуального баланса
                        }
                    }
                    .listRowBackground(Color.black)
                    .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
               
                    .listRowSeparator(.hidden)   // Убираем стандартные разделители списка
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
                    AddTaskView(viewModel: viewModel)
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





struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
