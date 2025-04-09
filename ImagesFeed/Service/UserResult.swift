import Foundation

struct UserResult: Codable {
    let avatarPhoto: ProfileImage
    
    enum CodingKeys: String, CodingKey {
        case avatarPhoto = "profile_image"
    }
}

struct ProfileImage: Codable {
    let small: String
}
