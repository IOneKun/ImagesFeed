import Foundation
import UIKit
import SwiftKeychainWrapper

final class SplashViewController: UIViewController {
    private let showAuthScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let profileService = ProfileService.shared
    private let tokenStorage = OAuth2TokenStorage()
    private let imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        let image = UIImage(named: "splash_screen_logo")
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([ imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                      imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
                                    ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let token = tokenStorage.token  {
            print("Сохраненный токен найден \(token)")
            fetchProfile(token)
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            let authVC = storyboard.instantiateViewController(withIdentifier: "AuthViewController")
            
            
            authVC.modalPresentationStyle = .fullScreen
            self.present(authVC, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            print("Окно не найдено")
            return
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main).instantiateViewController(withIdentifier: "TabBarController")
        window.rootViewController = tabBarController
    }
}


extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        guard let token = tokenStorage.token else {
            print("Токен отсутствует после авторизации")
            return
        }
        fetchProfile(token)
        print("Подготовка профиля началась...")
    }
    
    private func fetchProfile(_ token: String) {
        guard let token = OAuth2TokenStorage().token else {
            print("Токена нет")
            return
        }
        profileService.fetchProfile(token) { result in
            switch result {
            case .success(let profile):
                print("Профиль получен и создан успешно")
                ProfileImageService.shared.fetchProfileImageURL(username: profile.username) { _ in
                    print("Вызов FetchProfileImageURL")
                    DispatchQueue.main.async {
                        self.switchToTabBarController()
                    }
                }
            case .failure(_):
                print("Ошибка при получении профиля")
            }
        }
    }
}

