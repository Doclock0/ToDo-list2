import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TaskListViewModel()
    @State private var newTaskTitle = ""
    @State private var showAddTaskView = false
    @State private var selectedTask: TaskEntity?

    var body: some View {
        NavigationStack {
            VStack {
                // Поиск
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .padding(.leading, 10)
                    TextField("Поиск", text: $viewModel.searchText)
                        .foregroundColor(.white)
                        .padding(8)
                        .background(Color(red: 39/255, green: 39/255, blue: 41/255))
                        .cornerRadius(8)
                }
                .frame(height: 36)
                .background(Color(red: 39 / 255, green: 39 / 255, blue: 41 / 255))
                .cornerRadius(8)
                .padding(.top, 10)
                .padding(.bottom, 8)
                .padding(.horizontal, 20)

                // Список задач
                List {
                    ForEach(viewModel.filteredTasks.indices, id: \.self) { index in
                        if index < viewModel.filteredTasks.count {
                            let task = viewModel.filteredTasks[index]
                            NavigationLink(value: task) {
                                VStack(spacing: 0) {
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

                                            if let description = task.descriptionText, !description.isEmpty {
                                                Text(description)
                                                    .font(.subheadline)
                                                    .foregroundColor(task.isCompleted ? Color.gray : Color.white)
                                                    .lineLimit(2)
                                            }

                                            if let date = task.date, !date.isEmpty {
                                                Text(date)
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding(.vertical, 12)

                                    Rectangle()
                                        .fill(Color.gray)
                                        .frame(height: 0.5)
                                }
                                .transition(.opacity)
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
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            viewModel.deleteTask(at: IndexSet(integer: index))
                                        }
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
                                .foregroundColor(Color.yellow)
                        }
                    }
                    .padding(.trailing, 22)
                }
                .frame(height: 49)
                .background(Color(red: 39 / 255, green: 39 / 255, blue: 41 / 255))
                .sheet(isPresented: $showAddTaskView) {
                    AddTaskView(viewModel: viewModel)
                }
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
            .background(Color.black)
            .navigationDestination(for: TaskEntity.self) { task in
                TaskDetailView(task: task)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
