import Foundation

final class NetworkClient {
    private let urlSession = URLSession.shared
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let task = urlSession.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let decodedObject = try decoder.decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    print("Ошибка декодирования: \(error.localizedDescription)")
                    completion(.failure(error))
                    if let stringData = String(data: data, encoding: .utf8) {
                        print("Полученные данные: \(stringData)")
                    } else {
                        print("Не удалось декодировать данные в строку")
                    }
                }
            case .failure(let error):
                print("Ошибка загрузки данных: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        return task
    }
}

