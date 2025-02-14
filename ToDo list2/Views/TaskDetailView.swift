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
            .padding(.top, 8) 
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("Детали")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold, design: .default))
                            .foregroundColor(Color(red: 254 / 255, green: 215 / 255, blue: 2 / 255))
                    }
                        Text("Назад") // Текст кнопки
                            .font(.system(size: 22))
                            .foregroundColor(Color(red: 254 / 255, green: 215 / 255, blue: 2 / 255))
                            .padding(.leading, 6)
                    }
                    .padding(.leading, -16)
                }
            
            }
        
        }
    }

