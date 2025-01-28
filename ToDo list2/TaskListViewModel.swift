//
//  TaskListViewModel.swift
//  ToDo list2
//
//  Created by Виктория Струсь on 28.01.2025.
//

import Foundation
import SwiftUI

class TaskListViewModel: ObservableObject {
    @Published var tasks: [Task] = [
        Task(title: "Почитать книгу", description: "Составить список необходимых продуктов для ужина. Не забывать проверить, что уже есть в холодильнике.", date: "09/10/24", isCompleted: true),
        Task(title: "Уборка в квартире", description: "Провести генеральную уборку в квартире", date: "02/10/24", isCompleted: false),
        Task(title: "Заняться спортом", description: "Сходить в спортзал или сделать тренировку дома. Не забывать про разминку и растяжку!", date: "02/10/24", isCompleted: false),
        Task(title: "Работа над проектом", description: "Выделить время для работы над проектом на работе. Сфокусироваться на выполнении важных задач.", date: "09/10/24", isCompleted: true),
        Task(title: "Вечерний отдых", description: "Найти время для расслабления перед сном: посмотреть фильм или послушать музыку.", date: "02/10/24", isCompleted: false)
    ]
    
    func addTask(_ task: Task) {
        tasks.append(task)
    }
    
    func toggleCompletion(for task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].isCompleted.toggle()
        }
    }
}
