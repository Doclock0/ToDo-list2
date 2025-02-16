import SwiftUI

struct ContentView: View {
    // MARK: - State Variables
    @StateObject private var viewModel = TaskListViewModel()
    @State private var isAddTaskViewPresented = false
    @State private var selectedTaskForEditing: TaskEntity?
    @FocusState private var isSearchFieldFocused: Bool

    var body: some View {
        NavigationStack {
            VStack {
                searchField
                taskList
                footer
            }
            .background(Color.black)
            .sheet(isPresented: $isAddTaskViewPresented) {
                AddTaskView(viewModel: viewModel)
            }
            .sheet(item: $selectedTaskForEditing) { task in
                EditTaskView(viewModel: viewModel, task: task)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Задачи")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .font(.system(size: 34, weight: .bold))
                        .padding(.top, 3)
                        .padding(.bottom, 8)
                }
            }
            .navigationDestination(for: TaskEntity.self) { task in
                TaskDetailView(task: task)
            }
            .onTapGesture {
                // Скрываем клавиатуру при нажатии вне текстового поля
                isSearchFieldFocused = false
            }
            .onAppear {
                // Убедимся, что фокус не активируется автоматически при открытии приложения
                isSearchFieldFocused = false
            }
        }
    }
    
    // MARK: - Components
    
    // Поисковая строка
    @ViewBuilder
    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(.leading, 10)
            
            ZStack(alignment: .leading) {
                // Плейсхолдер для пустого поля поиска
                if viewModel.searchText.isEmpty {
                    Text("Search")
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                }

                // Поле ввода текста
                TextField("", text: $viewModel.searchText)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.clear)
                    .cornerRadius(8)
                    .focused($isSearchFieldFocused) // Управление фокусом
                    .onTapGesture {
                        // Активируем фокус только при явном нажатии на TextField
                        isSearchFieldFocused = true
                    }
            }
        }
        .frame(height: 36)
        .background(Color(red: 39 / 255, green: 39 / 255, blue: 41 / 255))
        .cornerRadius(8)
        .padding(.top, 10)
        .padding(.bottom, 8)
        .padding(.horizontal, 20)
    }
    
    // Список задач
    @ViewBuilder
    private var taskList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.filteredTasks.indices, id: \.self) { index in
                    if index < viewModel.filteredTasks.count {
                        let task = viewModel.filteredTasks[index]
                        VStack(spacing: 0) {
                            // Разделитель сверху
                            if index > 0 {
                                Rectangle()
                                    .fill(Color.gray)
                                    .frame(height: 1)
                                    .opacity(0.5)
                            }
                            
                            // Строка задачи
                            NavigationLink(value: task) {
                                taskRow(task: task, index: index)
                            }
                            .background(Color.black)
                            .contextMenu {
                                // Контекстное меню для редактирования и удаления задачи
                                Button {
                                    selectedTaskForEditing = task
                                } label: {
                                    Label("Редактировать", systemImage: "pencil")
                                }
                                Button(role: .destructive) {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        viewModel.deleteTask(at: IndexSet(integer: index))
                                    }
                                } label: {
                                    Label("Удалить", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .padding(.leading, 20)
            .padding(.trailing, 20)
        }
        .scrollDismissesKeyboard(.immediately) // Скрываем клавиатуру при скролле
    }
    
    // Футер
    @ViewBuilder
    private var footer: some View {
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
                    isAddTaskViewPresented.toggle()
                }) {
                    Image(systemName: "square.and.pencil")
                        .resizable()
                        .frame(width: 22, height: 22)
                        .foregroundColor(Color.yellow)
                }
            }
            .padding(.trailing, 22)
        }
        .frame(height: 49)
        .background(Color(red: 39 / 255, green: 39 / 255, blue: 41 / 255))
    }
    
    // Строка задачи
    @ViewBuilder
    private func taskRow(task: TaskEntity, index: Int) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // Круг для отметки выполнения задачи
            ZStack {
                Circle()
                    .stroke(task.isCompleted ? Color.yellow : Color.gray, lineWidth: 1.5)
                    .frame(width: 24, height: 24)
                    .onTapGesture {
                        withAnimation {
                            viewModel.toggleCompletion(for: task)
                        }
                        isSearchFieldFocused = false // Убираем фокус с поиска
                    }
                if task.isCompleted {
                    Image(systemName: "checkmark")
                        .resizable()
                        .frame(width: 12, height: 9)
                        .foregroundColor(Color.yellow)
                }
            }
            
            // Текст задачи
            VStack(alignment: .leading, spacing: 6) {
                Text(task.title ?? "")
                    .lineLimit(1)
                    .font(.headline)
                    .strikethrough(task.isCompleted)
                    .foregroundColor(task.isCompleted ? Color.gray : Color.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)
                
                if let description = task.descriptionText, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(task.isCompleted ? Color.gray : Color.white)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                } else {
                    Text("нет описания")
                        .font(.subheadline)
                        .foregroundColor(task.isCompleted ? Color.gray : .white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                }
                
                if let date = task.date, !date.isEmpty {
                    Text(date)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                } else {
                    Text("нет даты")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 12)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
