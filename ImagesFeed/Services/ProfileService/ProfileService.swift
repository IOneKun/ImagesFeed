import Foundation

final class ProfileService {
    
    enum NetworkError: Error {
        case requestError
    }
    
    static let shared = ProfileService()
    private let urlSession = URLSession.shared
    private let baseURL = "https://api.unsplash.com"
    private(set) var profile: Profile?
    let client = NetworkClient()
    private init() {} 
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "\(baseURL)/me") else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        guard let request = makeProfileRequest(token: token) else {
            print("[ProfileService]: NetworkError - Ошибка в создании запроса")
            completion(.failure(NetworkError.requestError))
            return
        }
        let task = client.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let profileResult):
                let name = (profileResult.firstName ?? "") + " " + (profileResult.lastName ?? "")
                let loginName = "@" + (profileResult.username ?? "")
                let profile = Profile(
                    username: profileResult.username ?? "",
                    name: name,
                    loginName: loginName,
                    bio: profileResult.bio
                )
                print("Username для загрузки аватарки: \(profile.username)")
                self.profile = profile
                print("Профиль получен")
                completion(.success(profile))
                
            case .failure(let error):
                print("[ProfileService]: \(type(of: error)) - \(error.localizedDescription), с кодом: \(error)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
    func clean() {
        self.profile = nil 
    }
}
