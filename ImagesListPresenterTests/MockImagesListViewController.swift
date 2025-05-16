    import Foundation

    class MockImagesListViewController: ImagesListViewControllerProtocol {
        
        var updateTableViewAnimatedCalled = false
        var updateLikeCalled = false
        var showLikeErrorCalled = false 
        
        func updateTableViewAnimated(oldCount: Int, newCount: Int) {
            updateTableViewAnimatedCalled = true
        }
        
        func updateLike(at index: Int, isLiked: Bool) {
            updateLikeCalled = true
        }
        
        func showLikeError() {
            showLikeErrorCalled = true 
        }
    }
        class MockImagesListService: ImagesListServiceProtocol {
            var photos: [Photo] = []
            var fetchPhotosCalled = false
            var changeLikeCalled = false
            var shouldFailLike = false
            
            func fetchPhotosNextPage() {
                fetchPhotosCalled = true
            }
            
            func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, any Error>) -> Void) {
                changeLikeCalled = true
                if shouldFailLike {
                    completion(.failure(NSError(domain: "", code: 0, userInfo: nil)))
                } else {
                    completion(.success(()))
                }
            }
        }
