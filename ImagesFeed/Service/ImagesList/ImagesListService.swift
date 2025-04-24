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
                print("Ошибка загрузки фото: \(error)")
            }
        }
    }
}
