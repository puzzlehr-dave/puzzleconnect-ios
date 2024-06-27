
import NotPWA2

// for now this is a dumb class that just mirrors the JS state eventually should integrate with keychain

class Auth {
    static var token: String? {
        didSet { NotificationCenter.default.post(name: Notification.Name("ConfigureNotifications"), object: nil) }
    }
}

struct TokenUpdate: Codable {
    let token: String?
}
