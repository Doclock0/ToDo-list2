import Foundation
import Combine

class NetworkManager {
    static let shared = NetworkManager()
    private let environment: APIEnvironment = .firstURL
    
    private init() {}

    func loadTasksFromAPI() -> AnyPublisher<[Task], APIError> {
        guard let url = URL(string: environment.baseURL) else {
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { output -> Data in
                // Проверяем статус HTTP-ответа
                if let httpResponse = output.response as? HTTPURLResponse,
                   !(200...299).contains(httpResponse.statusCode) {
                    throw APIError.serverError(statusCode: httpResponse.statusCode)
                }
                return output.data
            }
            .decode(type: TodoResponse.self, decoder: JSONDecoder())
            .mapError { error -> APIError in
                // Преобразуем ошибку в APIError
                if let apiError = error as? APIError {
                    return apiError
                } else if let decodingError = error as? DecodingError {
                    return .decodingError
                } else {
                    return .networkError
                }
            }
            .map(\.todos)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    enum APIEnvironment {
        case firstURL
        case secondURL
    
        var baseURL: String {
            switch self {
            case .firstURL:
                return "https://dummyjson.com/todos"
            case .secondURL:
                return "example"
            }
        }
    }

    // Перечисление ошибок
    enum APIError: Error, LocalizedError {
        case invalidURL
        case networkError
        case serverError(statusCode: Int)
        case decodingError

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "Неверный URL"
            case .networkError:
                return "Ошибка сети. Проверьте соединение."
            case .serverError(let statusCode):
                return "Ошибка сервера. Код: \(statusCode)"
            case .decodingError:
                return "Ошибка обработки данных"
            }
        }
    }
}
