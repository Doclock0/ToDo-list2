//
//  TaskCoreDataManager.swift
//  ToDo list2
//
//  Created by Виктория Струсь on 11.02.2025.
//

import CoreData
import Foundation

class TaskCoreDataManager {
    static let shared = TaskCoreDataManager()
    let context: NSManagedObjectContext

    private init() {
        context = PersistenceController.shared.container.viewContext
    }

    // Сохранение задачи
    func saveTask(id: Int, title: String, description: String?, date: String, isCompleted: Bool) {
        let taskEntity = TaskEntity(context: context)
        taskEntity.id = Int64(id)
        taskEntity.title = title
        taskEntity.descriptionText = description
        taskEntity.date = date
        taskEntity.isCompleted = isCompleted

        saveContext()
    }

    // Загрузка всех задач
    func fetchTasks() -> [Task] {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()

        // Сортировка по id
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [sortDescriptor]

        do {
            let entities = try context.fetch(request)
            return entities.map { entity in
                Task(
                    id: Int(entity.id),
                    title: entity.title ?? "",
                    descriptionText: entity.descriptionText,
                    date: entity.date ?? "",
                    isCompleted: entity.isCompleted
                )
            }
        } catch {
            print("Ошибка загрузки задач: \(error)")
            return []
        }
    }

    // Удаление задачи
    func deleteTask(id: Int) {
        let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", id)

        do {
            if let entity = try context.fetch(request).first {
                context.delete(entity)
                saveContext()
            }
        } catch {
            print("Ошибка удаления задачи: \(error)")
        }
    }

    // Сохранение изменений в контексте
    private func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Ошибка сохранения контекста: \(error)")
            }
        }
    }
    // Изменение задачи
    func updateTask(task: TaskEntity, newTitle: String, newDescription: String, newDate: Date) {
        task.title = newTitle
        task.descriptionText = newDescription
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        task.date = dateFormatter.string(from: newDate)
        
        saveContext() // Сохраняем изменения в CoreData
    }
}
