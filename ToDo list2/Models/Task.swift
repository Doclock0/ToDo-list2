//
//  Task.swift
//  ToDo list2
//
//  Created by Виктория Струсь on 28.01.2025.
//
import Foundation

struct Task: Identifiable, Decodable, Hashable {
    var id: Int
    var title: String
    var descriptionText: String?
    var date: String = ""
    var isCompleted: Bool
    
    private enum CodingKeys: String, CodingKey {
        case id
        case title = "todo"
        case isCompleted = "completed"
    }
}

struct TodoResponse: Decodable {
    var todos: [Task]
}
