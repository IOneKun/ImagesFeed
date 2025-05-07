import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imagesListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    weak var delegate: ImagesListCellDelegate?
    
    @IBAction func likeButtonClicked(_ sender: UIButton) {
        print("Лайк нажат")
        delegate?.imagesListCellDidTapLike(self)
    }
    
    static let reuseIdentifier = "ImagesListCell"
    
    override func prepareForReuse() {
        super.prepareForReuse()
       
        cellImage.kf.cancelDownloadTask()
    }
    
    func setImage(url: URL, completion: @escaping () -> Void) {
        cellImage.kf.indicatorType = .activity
        print("Индикатор загрузки вызван")
        cellImage.kf.setImage(with: url,
                              placeholder: UIImage(named: "Zaglushka"),
                              options: [.transition(.fade(0.8))]
        ) { _ in
            completion() 
        }
    }
    func setIsLiked(_ isLiked: Bool) {
        let likeImage = isLiked ? UIImage(named: "like_Button") : UIImage(named: "dislike_Button")
        likeButton.setImage(likeImage, for: .normal)
    }
}

