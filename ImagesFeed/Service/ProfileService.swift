import Foundation

final class ProfileService {
    
    static let shared = ProfileService()
    private let urlSession = URLSession.shared
    private let baseURL = "https://api.unsplash.com"
    private(set) var profile: Profile?
    
    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "\(baseURL)/me") else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print("Токен получен")
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        guard let request = makeProfileRequest(token: token) else {
            //TODO: Поменять это
            completion(.failure(NSError(domain: "ProfileService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create request"])))
            return
        }
        let task = urlSession.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                //TODO: Поменять это
                completion(.failure(NSError(domain: "ProfileService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            if let data = String(data: data, encoding: .utf8) {
                print("\(data)")
            } else {
                print("Не удалось получить данные")
            }
            
            do {
                let decoder = JSONDecoder()
                let profileResult = try decoder.decode(ProfileResult.self, from: data)
                let name = (profileResult.firstName ?? "") + " " + (profileResult.lastName ?? "")
                let loginName = "@" + (profileResult.username ?? "")
                let profile = Profile(username: profileResult.username ?? "",
                                      name: name,
                                      loginName: loginName,
                                      bio: profileResult.bio)
                print("Получен профиль: \(profileResult)")
                self.profile = profile
                DispatchQueue.main.async {
                    completion(.success(profile))
                }
            } catch {
                completion(.failure(error))
                print("Профиль из \(data) не декодировался")
            }
        }
        task.resume()
    }
}
