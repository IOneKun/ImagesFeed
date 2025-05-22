import XCTest

@testable import ImagesFeed

final class ImagesListPresenterTests: XCTestCase {

    func test_viewDidLoadFetchPhotosUpdatesTable() {
       
        let mockService = MockImagesListService()
        mockService.photos = [makePhoto()]
        let mockView = MockImagesListViewController()
        let presenter = ImagesListPresenter(imagesListService: mockService as ImagesListServiceProtocol)
        presenter.setView(mockView as ImagesListViewControllerProtocol)

    
        presenter.viewDidLoad()

        XCTAssertTrue(mockService.fetchPhotosCalled)
    }

    func testdidTapLikeSuccessUpdatesLike() {
        // Arrange
        let mockService = MockImagesListService()
        mockService.photos = [makePhoto()]
        let mockView = MockImagesListViewController()
        let presenter = ImagesListPresenter(imagesListService: mockService as ImagesListServiceProtocol)
        presenter.setView(mockView as ImagesListViewControllerProtocol)
        presenter.viewDidLoad()

    
        presenter.didTapLike(at: 0)

   
        XCTAssertTrue(mockService.changeLikeCalled)
    }

    func testDidTapLikeFailureShowsError() {
    
        let mockService = MockImagesListService()
        mockService.shouldFailLike = true
        mockService.photos = [makePhoto()]
        let mockView = MockImagesListViewController()
        let presenter = ImagesListPresenter(imagesListService: mockService as ImagesListServiceProtocol)
        presenter.setView(mockView as ImagesListViewControllerProtocol)
        presenter.viewDidLoad()

       
        presenter.didTapLike(at: 0)

   
        XCTAssertTrue(mockView.showLikeErrorCalled)
    }
}

private func makePhoto() -> Photo {
    return Photo(
        id: "test",
        size: CGSize(width: 100, height: 100),
        createdAt: nil,
        welcomeDescription: nil,
        thumbImageUrl: URL(string: "https:")!,
        isLiked: false,
        fullImageURL: URL(string: "https:")!
    )
}

