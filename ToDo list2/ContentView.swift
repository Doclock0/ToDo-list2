//
//  ContentView.swift
//  ToDo list2
//
//  Created by Виктория Струсь on 28.01.2025.
//

import SwiftUI
import CoreData

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
                    TextField("Search", text: $newTaskTitle)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                
                // Список задач
                List {
                    ForEach(viewModel.tasks) { task in
                        HStack(alignment: .top) {
                            // Чекбокс
                            Circle()
                                .fill(task.isCompleted ? Color.yellow : Color.clear)
                                .frame(width: 20, height: 20)
                                .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(task.title)
                                    .font(.headline)
                                    .foregroundColor(task.isCompleted ? Color.gray : Color.white)
                                    .strikethrough(task.isCompleted)
                                
                                if !task.description.isEmpty {
                                    Text(task.description)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .lineLimit(2)
                                }
                                
                                if !task.date.isEmpty {
                                    Text(task.date)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.leading, 8)
                        }
                        .padding(.vertical, 4)
                        .onTapGesture {
                            viewModel.toggleCompletion(for: task)
                        }
                    }
                    .listRowBackground(Color.black)
                    .listRowSeparator(.hidden)
                }
                .listStyle(PlainListStyle())
                .background(Color.black.edgesIgnoringSafeArea(.all))
                .preferredColorScheme(.dark)
                
                
                
                // Кнопка для добавления новой задачи
                Button(action: {
                    showAddTaskView.toggle()
                }) {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(50)
                }
                .sheet(isPresented: $showAddTaskView) {
                    AddTaskView(tasks: $viewModel.tasks)
                }
            }
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Задачи")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .padding(.top, 3)
                        .padding(.leading, 20)
                        .padding(.bottom, 8)
                        .font(.system(size: 34, weight: .bold))
                    
                }
            }
            .background(Color(red: 4/255, green: 4/255, blue: 4/255))
            
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
                    }
                }
            }
            
            struct ContentView_Previews: PreviewProvider {
                static var previews: some View {
                    ContentView()
                }
            }
        
    

