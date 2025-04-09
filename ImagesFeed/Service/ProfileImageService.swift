import Foundation

final class ProfileImageService {
    private let urlSession = URLSession.shared
    private let baseURL = "https://api.unsplash.com"
    static let shared = ProfileImageService()
    private init () {}
    private(set) var avatarURL: String?
    
    enum ProfileImageServiceError: Error {
        case invalidURL
        case noData
        case noToken
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>)-> Void) {
        guard let token = OAuth2TokenStorage().token else {
            completion(.failure(ProfileImageServiceError.noToken))
            return
        }
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            completion(.failure(ProfileImageServiceError.invalidURL))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = urlSession.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(ProfileImageServiceError.noData))
                return
            }
            
            do {
                let userResult = try JSONDecoder().decode(UserResult.self, from: data)
                self.avatarURL = userResult.avatarPhoto.small
                completion(.success(userResult.avatarPhoto.small))
                print("Фото получено")
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
