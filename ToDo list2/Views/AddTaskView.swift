//
//  AddTaskView.swift
//  ToDo list2
//
//  Created by Виктория Струсь on 11.02.2025.
//

import Foundation
import SwiftUI

struct AddTaskView: View {
    @ObservedObject var viewModel: TaskListViewModel
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
                        dateFormatter.dateFormat = "dd/MM/yy"
                        let formattedDate = dateFormatter.string(from: newTaskDate)
                        
                        //  Передаём данные в ViewModel
                        viewModel.addTask(
                            title: newTaskTitle,
                            description: newTaskDescription,
                            date: formattedDate
                        )
                        
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(newTaskTitle.isEmpty)
                }
            }
        }
    }
}
