import Foundation
import Combine

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}

    private let baseURL = "https://dummyjson.com/todos"

    func loadTasksFromAPI() -> AnyPublisher<[Task], Error> {
        guard let url = URL(string: baseURL) else {
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: TodoResponse.self, decoder: JSONDecoder())
            .map(\.todos)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
