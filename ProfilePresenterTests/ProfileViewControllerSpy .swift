import Foundation

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var updateUICalled = false
    var updateAvatarCalled = false
    var showLogoutAlertCalled = false
    var receivedProfile: Profile?
    var receivedURL: URL?

    func updateUI(_ profile: Profile) {
        updateUICalled = true
        receivedProfile = profile
    }

    func updateAvatar(_ url: URL) {
        updateAvatarCalled = true
        receivedURL = url
    }

    func showLogoutAlert() {
        showLogoutAlertCalled = true
    }
}

final class MockProfileService: ProfileServiceProtocol {
    var profile: Profile?

    init(profile: Profile? = nil) {
        self.profile = profile
    }
}

final class MockProfileImageService: ProfileImageServiceProtocol {
    var avatarURL: String?

    init(avatarURL: String? = nil) {
        self.avatarURL = avatarURL
    }
}

