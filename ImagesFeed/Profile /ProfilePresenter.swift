import Foundation

protocol ProfilePresenterProtocol {
    func setView(_ view: ProfileViewControllerProtocol)
    func viewDidLoad()
    func didTapExitButton()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    
    weak var view: ProfileViewControllerProtocol?
    
    private let profileService: ProfileServiceProtocol
    private let profileImageService: ProfileImageServiceProtocol
    
    init(profileService: ProfileServiceProtocol = ProfileService.shared,
         profileImageService: ProfileImageServiceProtocol = ProfileImageService.shared) {
        self.profileService = profileService
        self.profileImageService = profileImageService
    }
    
    func setView(_ view: ProfileViewControllerProtocol) {
        self.view = view
    }
    
    func viewDidLoad() {
        guard let profile = profileService.profile else {
            print("Профиль не найден")
            return
        }
        view?.updateUI(profile)
        
        guard let urlString = profileImageService.avatarURL,
              let url = URL(string: urlString) else {
            print("Неверный или пустой URL аватара")
            return
        }
        view?.updateAvatar(url)
    }
    
    func didTapExitButton() {
        view?.showLogoutAlert()
    }
}

