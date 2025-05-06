import Foundation

final class ImagesListService {
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    var photos: [Photo] = []
    var lastLoadedPage: Int?
    var isLoading = false
    
    
    func fetchPhotosNextPage() {
        guard !isLoading else { return }
        
        isLoading = true
        
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        ImagesListClient.shared.fetchPhotos(page: nextPage) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            
            switch result {
            case .success(let newPhotos):
                self.lastLoadedPage = nextPage
                
                let filteredPhotos = newPhotos.filter { newPhotos in
                    !self.photos.contains(where: { $0.id == newPhotos.id })
                }
                DispatchQueue.main.async{
                    self.photos.append(contentsOf: filteredPhotos)
                    NotificationCenter.default.post(
                        name: ImagesListService.didChangeNotification,
                        object: self
                    )
                }
            case .failure(let error):
                print("[ImagesListService]: Ошибка загрузки фото \(error.localizedDescription)")
            }
        }
    }
    
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let url = URL(string: "https://api.unsplash.com/photos/\(photoId)/like") else {
            print("[ImagesListService] Неверный URL для запроса лайков")
            completion(.failure(NSError(domain: "Неверный URL", code: 0)))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        
        if let token = OAuth2TokenStorage.share.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("[ImagesListService] Нет токена")
            completion(.failure(NSError(domain: "Нет токена", code: 0)))
            return
        }
        let task = NetworkClient().objectTask(for: request) { (result: Result<LikePhotoResult, Error>) in
            switch result {
            case .success(_):
                DispatchQueue.main.async {
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        let photo = self.photos[index]
                        let newPhoto = Photo(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt,
                            welcomeDescription: photo.welcomeDescription,
                            thumbImageUrl: photo.thumbImageUrl,
                            isLiked: !photo.isLiked,
                            fullImageURL: photo.fullImageURL
                        )
                        self.photos[index] = newPhoto
                    }
                    completion(.success(()))
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    print("[ImagesListService]: Ошибка запроса лайков \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    func clean() {
        print("[ImagesListService]: Очистка данных")
        photos = []
        lastLoadedPage = nil
        isLoading = false 
    }
}
