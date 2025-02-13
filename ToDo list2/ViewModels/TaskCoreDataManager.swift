import CoreData
import Foundation

class TaskCoreDataManager {
    static let shared = TaskCoreDataManager()
    let context: NSManagedObjectContext // Основной контекст для чтения данных
    let backgroundContext: NSManagedObjectContext // Фоновый контекст для записи

    private init() {
        context = PersistenceController.shared.container.viewContext
        backgroundContext = PersistenceController.shared.backgroundContext // фоновый контекст из PersistenceController
    }

    // Сохранение задачи
    func saveTask(id: Int, title: String, description: String?, date: String, isCompleted: Bool) {
        backgroundContext.perform {
            let taskEntity = TaskEntity(context: self.backgroundContext)
            taskEntity.id = Int64(id)
            taskEntity.title = title
            taskEntity.descriptionText = description
            taskEntity.date = date
            taskEntity.isCompleted = isCompleted

            do {
                try self.backgroundContext.save()
            } catch {
                print("Ошибка сохранения задачи: \(error)")
            }
        }
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
        backgroundContext.perform {
            let request: NSFetchRequest<TaskEntity> = TaskEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d", id)

            do {
                if let entity = try self.backgroundContext.fetch(request).first {
                    self.backgroundContext.delete(entity)
                    try self.backgroundContext.save()
                }
            } catch {
                print("Ошибка удаления задачи: \(error)")
            }
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
        backgroundContext.perform {
            task.title = newTitle
            task.descriptionText = newDescription
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yy"
            task.date = dateFormatter.string(from: newDate)

            do {
                try self.backgroundContext.save()
            } catch {
                print("Ошибка обновления задачи: \(error)")
            }
        }
    }
}
