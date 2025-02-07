//
//  Task.swift
//  ToDo list2
//
//  Created by Виктория Струсь on 28.01.2025.
//

import Foundation
import SwiftUI

struct Task: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var description: String
    var date: String
    var isCompleted: Bool
}
