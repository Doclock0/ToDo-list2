import SwiftUI

struct TaskDetailView: View {
    let task: Task
    @Environment(\.dismiss) private var dismiss // Для возврата назад
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 16) {
                // Название задачи
                Text(task.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Дата
                Text(task.date)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                // Описание
                if let description = task.description, !description.isEmpty {
                    Text(description)
                        .font(.body)
                        .foregroundColor(.white)
                        .padding(.top, 8)
                        .lineLimit(nil) // Убираем ограничение на количество строк, чтобы текст всегда переносился на новые строки
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
                        Image(systemName: "chevron.left") // Иконка назад
                            .foregroundColor(Color(red: 254 / 255, green: 215 / 255, blue: 2 / 255)) // Цвет иконки
                        Text("Назад") // Текст кнопки
                            .font(.system(size: 17))
                            .foregroundColor(Color(red: 254 / 255, green: 215 / 255, blue: 2 / 255)) // Цвет текста
                            .padding(.leading, 6)
                    }
                    .padding(.leading, 6)
                }
            }
        }
    }
}
