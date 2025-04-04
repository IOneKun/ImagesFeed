import Foundation

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: Constants.baseURLString) else {
            print("Некорректный базовый URL: \(Constants.baseURLString)")
            return nil
        }
        
        var components = URLComponents()
        components.path = "/oauth/token"
        components.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = components.url(relativeTo: baseURL) else {
            assertionFailure("Не удалось создать URL для OAuth")
            print("Не удалось создать URL. BaseURL: \(baseURL.absoluteString), Path: \(components.path)")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if task != nil {
            if lastCode != code {
                task?.cancel()
            } else {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        } else {
            if lastCode == code {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        }
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("Не удалось создать URLrequest для OAuthToken")
            completion(.failure(NetworkError.invalidURLComponents))
            return
        }
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.task = nil
                self.lastCode = nil
                
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(AuthServiceError.invalidRequest))
                    return
                }
                do {
                    let tokenResponse = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data)
                    let token = tokenResponse.accessToken
                    OAuth2TokenStorage().token = token
                    completion(.success(token))
                } catch {
                    completion(.failure(error))
                }
            }
        }
        self.task = task
        task.resume()
    }
}
