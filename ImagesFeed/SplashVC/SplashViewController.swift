import Foundation
import UIKit

final class SplashViewController: UIViewController {
    private let showAuthScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let profileService = ProfileService.shared 
    private let tokenStorage = OAuth2TokenStorage()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = tokenStorage.token  {
            print("Сохраненный токен найден \(token)")
            fetchProfile(token)
        } else {
            performSegue(withIdentifier: showAuthScreenSegueIdentifier, sender: nil)
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

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthScreenSegueIdentifier {
            guard let navigationController = segue.destination as? UINavigationController,
                  let viewController = navigationController.viewControllers.first as? AuthViewController else {
                print("Не удалось выполнить переход по \(showAuthScreenSegueIdentifier)")
                return
            }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
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
                case .success(_):
                DispatchQueue.main.async {
                    self.switchToTabBarController()
                }
                    print("Профиль получен и создан успешно")
                case .failure(_):
                    print("Ошибка при получении профиля")
                }
            }
    }
}

