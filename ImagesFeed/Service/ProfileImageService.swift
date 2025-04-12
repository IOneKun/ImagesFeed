import Foundation

final class ProfileImageService {
    private let urlSession = URLSession.shared
    private let baseURL = "https://api.unsplash.com"
    static let shared = ProfileImageService()
    private init () {}
    private(set) var avatarURL: String?
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private let client = NetworkClient()
    
    enum ProfileImageServiceError: Error {
        case invalidURL
        case noData
        case noToken
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>)-> Void) {
        guard let token = OAuth2TokenStorage().token else {
            print("[ProfileImageService]: NetworkError - Токен не найден")
            completion(.failure(ProfileImageServiceError.noToken))
            return
        }
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            print("[ProfileImageService]: NetworkError - Неверный URL для запроса: \(username)")
            completion(.failure(ProfileImageServiceError.invalidURL))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = client.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let userResult):
                self.avatarURL = userResult.avatarPhoto.small
                completion(.success(userResult.avatarPhoto.small))
                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": self.avatarURL ?? ""]
                )
            case .failure(let error):
                print("[ProfileImageService]: \(type(of: error)) - \(error.localizedDescription), код ошибки: \(error)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
