
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var apnToken: String?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        NotificationCenter.default.addObserver(forName: Notification.Name("ConfigureNotifications"),
                                               object: nil,
                                               queue: nil) { [weak self] _ in
            self?.configureNotifications()
        }
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { success, error in
            guard success else {
                print("APN authorization error")
                print(error?.localizedDescription ?? "")
                return
            }
            
            DispatchQueue.main.async { application.registerForRemoteNotifications() }
        }
        
        return true
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        apnToken = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        configureNotifications()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("APN registration error")
        print(error.localizedDescription)
    }
    
}

// MARK: Notification API

extension AppDelegate {
    
    func configureNotifications() {
        let api = "https://api.crm.geekydevelopment.com/notifications/tokens/update"
        
        guard let token = apnToken else { return }
        
        guard let url = URL(string: api) else { return }
        guard let authorization = Auth.token else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["token": token])
        request.addValue(authorization, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data else { return print("APN connection error") }
            guard let response = response as? HTTPURLResponse else { return print("APN response error") }
            guard response.statusCode == 200 else { return print("APN API error") }
            
            print("APN configured successfully")
        }.resume()
    }
    
}
