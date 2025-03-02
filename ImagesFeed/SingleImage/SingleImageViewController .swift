import UIKit

final class SingleImageViewController: UIViewController {
    
    var image: UIImage?
    
    
    @IBOutlet private var imageView: UIImageView!
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image 
    }
}
