import SwiftUI

struct TaskDetailView: View {
    let task: TaskEntity
    @Environment(\.dismiss) private var dismiss

    // Константы
    private let backButtonColor = Color(red: 254 / 255, green: 215 / 255, blue: 2 / 255)
    private let horizontalPadding: CGFloat = 20
    private let topPadding: CGFloat = 65

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            VStack(alignment: .leading) {
                Spacer().frame(height: 106) // Отступ для заголовка

                // Название задачи
                Text(task.title ?? "Без названия")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.bottom, 8)

                // Дата
                Text(task.date ?? "Без даты")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.top, 8) // Отступ между датой и описанием

                // Описание
                Text(task.descriptionText?.isEmpty == false ? task.descriptionText! : "Описание отсутствует")
                    .font(.body)
                    .foregroundColor(task.descriptionText?.isEmpty == false ? .white : .gray)
                    .lineLimit(nil)
                    .padding(.top, 16)

                Spacer()
            }
            .padding(.horizontal, horizontalPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .ignoresSafeArea(.container, edges: .top) // Игнорирование safe area для всего ZStack
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .overlay(
            Button(action: {
                dismiss()
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                    Text("Назад")
                        .font(.system(size: 22))
                }
                .foregroundColor(backButtonColor)
                .padding(.leading, 8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.black.opacity(0.01))
            .padding(.top, topPadding) // Отступ от самого верха экрана
            .ignoresSafeArea(.container, edges: .top) // Игнорирование safe area для кнопки
            , alignment: .topLeading
        )
    }
}
