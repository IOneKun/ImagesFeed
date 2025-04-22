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
    private let client = NetworkClient()
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if lastCode == code {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }

        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("[OAuth2Service]: NetworkError - Неверные URL Components")
            completion(.failure(NetworkError.invalidURLComponents))
            return
        }
        let task = client.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in
            guard let self = self else { return }
            
            self.task = nil
            self.lastCode = nil
            
            switch result {
            case .success(let tokenResponse):
                let token = tokenResponse.accessToken
                OAuth2TokenStorage.share.token = token
                completion(.success(token))
            case .failure(let error):
                print("[OAuth2Service]: \(type(of: error)) - \(error.localizedDescription), код ошибки: \(error)")
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
    
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
}

