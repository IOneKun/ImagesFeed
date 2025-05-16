import XCTest
@testable import ImagesFeed

final class ProfilePresenterTests: XCTestCase {

    func testUIAndAvatarwhenProfileAndURLExist() {
        let profile = Profile(username: "user", name: "Имя", loginName: "@user", bio: "bio")
        let imageURL = "https"
        let profileService = MockProfileService(profile: profile)
        let imageService = MockProfileImageService(avatarURL: imageURL)
        let presenter = ProfilePresenter(profileService: profileService, profileImageService: imageService)
        let view = ProfileViewControllerSpy()
        presenter.setView(view)


        presenter.viewDidLoad()

        XCTAssertTrue(view.updateUICalled, "UI не обновилось")
        XCTAssertTrue(view.updateAvatarCalled, "Аватар не обновился")
        XCTAssertEqual(view.receivedProfile?.username, "user")
        XCTAssertEqual(view.receivedURL?.absoluteString, imageURL)
    }

    func testProfileIsNil() {
   
        let profileService = MockProfileService(profile: nil)
        let imageService = MockProfileImageService(avatarURL: "https://example.com/avatar.jpg")
        let presenter = ProfilePresenter(profileService: profileService, profileImageService: imageService)
        let view = ProfileViewControllerSpy()
        presenter.setView(view)

   
        presenter.viewDidLoad()

        XCTAssertFalse(view.updateUICalled)
        XCTAssertFalse(view.updateAvatarCalled)
    }

    func testNotUpdateAvatarWhenURLisNil() {
        let profile = Profile(username: "user", name: "Имя", loginName: "@user", bio: "bio")
        let profileService = MockProfileService(profile: profile)
        let imageService = MockProfileImageService(avatarURL: nil)
        let presenter = ProfilePresenter(profileService: profileService, profileImageService: imageService)
        let view = ProfileViewControllerSpy()
        presenter.setView(view)

        presenter.viewDidLoad()

        XCTAssertTrue(view.updateUICalled)
        XCTAssertFalse(view.updateAvatarCalled)
    }

    func testDidTapExitButtonShowsLogoutAlert() {
 
        let profileService = MockProfileService()
        let imageService = MockProfileImageService()
        let presenter = ProfilePresenter(profileService: profileService, profileImageService: imageService)
        let view = ProfileViewControllerSpy()
        presenter.setView(view)
  
        presenter.didTapExitButton()

        XCTAssertTrue(view.showLogoutAlertCalled)
    }
}

