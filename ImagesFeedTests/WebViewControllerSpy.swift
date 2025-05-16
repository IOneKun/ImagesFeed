import Foundation


final class WebViewControllerSpy: WebViewControllerProtocol {
    var presenter: ImagesFeed.WebViewPresenterProtocol?
    
    var loadRequestCalled: Bool = false
    
    func load(request: URLRequest) {
        loadRequestCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {
        
    }
    func setProgressHidden(_ isHidden: Bool) {
        
    }
}
