import Foundation

final class ImagesListClient {
    
    static let shared = ImagesListClient()
    private let client = NetworkClient()
    private let photosPerPage = 10
    
    func fetchPhotos(page: Int, completion: @escaping (Result<[Photo], Error>)-> Void) {
        guard var urlComponents = URLComponents(string: "https://api.unsplash.com/photos") else {
            completion(.failure(NSError(domain: "Неверный URL", code: 0)))
            return
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per_page", value: "\(photosPerPage)") ]
        
        guard let url = urlComponents.url else {
            completion(.failure(NSError(domain: "Неверный URL", code: 0)))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Client-ID \(Constants.accessKey)", forHTTPHeaderField: "Authorization")
        
        let task = client.objectTask(for: request) { (result: Result<[PhotoResult], Error>) in
            switch result {
            case .success(let photoResults):
                let photos = photoResults.map { Photo(from: $0) }
                completion(.success(photos))
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
