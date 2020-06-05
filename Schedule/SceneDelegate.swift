import UIKit

@available(iOS 13.0, *)
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let tabBarController = window?.rootViewController as! UITabBarController? {
            switch SDefaults.defaultUser {
                case .student: tabBarController.selectedIndex = 0
                case .teacher: tabBarController.selectedIndex = 1
            }
        }
    }
    
}
