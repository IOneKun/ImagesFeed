
import UIKit

final class SingleImageViewController: UIViewController {
    
    var fullImageURL: URL?
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var scrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        
        loadFullImage()
    }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let image = imageView.image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
    
    private func loadFullImage() {
          guard let url = fullImageURL else { return }

          UIBlockingProgressHUD.show()

          imageView.kf.setImage(with: url) { [weak self] result in
              guard let self = self else { return }
              UIBlockingProgressHUD.dismiss()
              switch result {
              case .success(let imageResult):
                  self.imageView.image = imageResult.image
                  self.imageView.frame.size = imageResult.image.size
                  self.rescaleAndCenterImageInScrollView(image: imageResult.image)
              case .failure:
                  self.showError()
              }
          }
      }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    private func showError() {
        let alert = UIAlertController(title: "Что-то пошло не так", message: "Попробовать еще раз?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Не надо", style: .default))
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            self?.loadFullImage()
        })
        present(alert, animated: true)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
