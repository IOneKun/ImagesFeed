import UIKit
import Kingfisher

final class ImagesListCell: UITableViewCell {
    
    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
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
}

