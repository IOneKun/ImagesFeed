import Foundation

protocol ImagesListPresenterProtocol {
    func setView(_ view: ImagesListViewControllerProtocol)
    var view: ImagesListViewControllerProtocol? {get set}
    var photosCount: Int {get}
    func viewDidLoad()
    func photo(at index: Int) -> Photo
    func didTapLike(at index: Int)
    func willDisplayCell(at index: Int)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    
    let imagesListService: ImagesListServiceProtocol
    
    init(imagesListService: ImagesListServiceProtocol = ImagesListService.shared) {
        self.imagesListService = imagesListService
    }
        weak var view: ImagesListViewControllerProtocol?
        
        var photos: [Photo] = []
        
        lazy var dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMMM yyyy"
            formatter.locale = Locale(identifier: "ru_RU")
            return formatter
        }()
        
        var photosCount: Int {
            return photos.count
        }
        
        func viewDidLoad() {
            imagesListService.fetchPhotosNextPage()
            self.photos = imagesListService.photos
            
            NotificationCenter.default.addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                let oldCount = self.photos.count
                self.photos = self.imagesListService.photos
                let newCount = self.photos.count
                self.view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
            }
        }
        func setView(_ view: ImagesListViewControllerProtocol) {
            self.view = view
        }
        func photo(at index: Int) -> Photo {
            return photos[index]
        }
        
        func willDisplayCell(at index: Int) {
            if index == photos.count - 1 {
                imagesListService.fetchPhotosNextPage()
            }
        }
        
        func didTapLike(at index: Int) {
            let photo = photos[index]
            UIBlockingProgressHUD.show()
            
            imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    UIBlockingProgressHUD.dismiss()
                    switch result {
                    case .success:
                        self.photos = self.imagesListService.photos
                        let newLike = self.photos[index].isLiked
                        self.view?.updateLike(at: index, isLiked: newLike)
                    case .failure:
                        self.view?.showLikeError()
                    }
                }
            }
        }
    }
