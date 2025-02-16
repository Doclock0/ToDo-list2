import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TaskListViewModel()
    @State private var showAddTaskView = false
    @State private var selectedTask: TaskEntity?
    
    var body: some View {
        NavigationStack {
            VStack {
                searchField
                taskList
                footer
            }
            .background(Color.black)
            .sheet(isPresented: $showAddTaskView) {
                AddTaskView(viewModel: viewModel)
            }
            .sheet(item: $selectedTask) { task in
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
        }
    }
    
    // MARK: - Компоненты
    
    // Поисковая строка
    @ViewBuilder
    private var searchField: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(.leading, 10)
            ZStack(alignment: .leading) {
                // Плейсхолдер
                if viewModel.searchText.isEmpty {
                    Text("Search")
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                }

                // Поле ввода
                TextField("", text: $viewModel.searchText)
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.clear)
                    .cornerRadius(8)
                    .ignoresSafeArea(.keyboard)
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
        List {
            ForEach(viewModel.filteredTasks.indices, id: \.self) { index in
                if index < viewModel.filteredTasks.count {
                    let task = viewModel.filteredTasks[index]
                    NavigationLink(value: task) {
                        taskRow(task: task, index: index)
                    }
                    .listRowBackground(Color.black)
                    .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                    .listRowSeparator(.hidden)
                    .contextMenu {
                        Button {
                            selectedTask = task
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
            .animation(.easeInOut, value: viewModel.filteredTasks)
        }
        .listStyle(PlainListStyle())
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
                    showAddTaskView.toggle()
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
        VStack(spacing: 0) {
            if index > 0 {
                Rectangle()
                    .fill(Color.gray)
                    .frame(height: 0.5)
            }
            HStack(alignment: .top, spacing: 12) {
                ZStack {
                    Circle()
                        .stroke(task.isCompleted ? Color.yellow : Color.gray, lineWidth: 1.5)
                        .frame(width: 24, height: 24)
                        .onTapGesture {
                            withAnimation {
                                viewModel.toggleCompletion(for: task)
                            }
                        }
                    if task.isCompleted {
                        Image(systemName: "checkmark")
                            .resizable()
                            .frame(width: 12, height: 9)
                            .foregroundColor(Color.yellow)
                    }
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title ?? "")
                        .font(.headline)
                        .strikethrough(task.isCompleted)
                        .foregroundColor(task.isCompleted ? Color.gray : Color.white)
                    
                    // Описание задачи
                    if let description = task.descriptionText, !description.isEmpty {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(task.isCompleted ? Color.gray : Color.white)
                            .lineLimit(2)
                    } else {
                        Text("нет описания")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    // Дата задачи
                    if let date = task.date, !date.isEmpty {
                        Text(date)
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        Text("нет даты")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 12)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
