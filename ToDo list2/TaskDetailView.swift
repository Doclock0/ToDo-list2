//
//  TaskDetailView.swift
//  ToDo list2
//
//  Created by Виктория Струсь on 02.02.2025.
//

import SwiftUI

struct TaskDetailView: View {
    let task: Task
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Название задачи
            Text(task.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            // Дата задачи
            Text(task.date)
                .font(.caption)
                .foregroundColor(.gray)
            
            // Описание задачи
            Text(task.description)
                .font(.body)
                .foregroundColor(.white)
                .padding(.top, 8)
        }
        .padding()
        .background(Color.black)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    // Закрыть детальное представление
                }) {
                    Text("Назад")
                        .foregroundColor(.yellow)
                }
            }
        }
    }
}

