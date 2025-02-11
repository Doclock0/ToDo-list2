import SwiftUI

struct TaskDetailView: View {
    let task: TaskEntity
    @Environment(\.dismiss) private var dismiss // Для возврата назад
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 16) {
                // Название задачи
                Text(task.title ?? "Без названия")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Дата
                Text(task.date ?? "Без даты")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                // Описание
                if let description = task.descriptionText, !description.isEmpty {
                    Text(description)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.top, 8)
                        .lineLimit(nil)
                } else {
                    Text("Описание отсутствует")
                        .font(.body)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                }
                
                Spacer()
            }
            .padding(.top, 8) // Отступ сверху
            .padding(.horizontal, 20) // Отступ слева и справа
            .frame(maxWidth: .infinity, alignment: .leading) // Обеспечивает, что VStack растягивается на всю ширину
        }
        .navigationTitle("Детали") // Заголовок экрана
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true) // Компактный заголовок
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss() // Закрываем экран
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold, design: .default)) // Размер 17, вес semibold
                            .foregroundColor(Color(red: 254 / 255, green: 215 / 255, blue: 2 / 255)) // Цвет иконки
                    }
                        Text("Назад") // Текст кнопки
                            .font(.system(size: 22))
                            .foregroundColor(Color(red: 254 / 255, green: 215 / 255, blue: 2 / 255)) // Цвет текста
                            .padding(.leading, 6)
                    }
                    .padding(.leading, -16)
                }
            
            }
        
        }
    }

