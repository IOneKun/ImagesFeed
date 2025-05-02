import Foundation

struct PhotoResult: Decodable {
    let id: String
    let width: Int
    let height: Int
    let color: String
    let likes: Int
    let likedByUser: Bool
    let description: String?
    let urls: URLResult
    
    enum CodingKeys: String, CodingKey {
        case id
        case width
        case height
        case color
        case likes
        case likedByUser = "liked_by_user"
        case description
        case urls
    }
}

struct URLResult: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date
    let welcomeDescription: String?
    let thumbImageUrl: URL
    let isLiked: Bool
    let fullImageURL: URL
}

struct LikePhotoResult: Decodable {
    let photo: PhotoResult 
}

extension Photo {
    init(from result: PhotoResult) {
        self.id = result.id
        self.size = CGSize(width: result.width, height: result.height)
        self.createdAt = Date()
        self.welcomeDescription = result.description
        self.thumbImageUrl = URL(string: result.urls.thumb)!
        self.isLiked = result.likedByUser
        self.fullImageURL = URL(string: result.urls.full)!
    }
}
