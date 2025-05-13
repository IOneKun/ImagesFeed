import Foundation

protocol ImagesListPresenter {
    var view: ImagesListViewControllerProtocol? { get set }
    func viewDidLoad()
    func imagesListDidTapLike()
}
