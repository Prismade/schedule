import UIKit

@available(iOS 13.0, *)
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  var window: UIWindow?
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    window = UIWindow(frame: UIScreen.main.bounds)
    
    let tabBarController = MainTabBarController()
    
    window?.rootViewController = tabBarController
    window?.makeKeyAndVisible()
    window?.windowScene = windowScene
  }
  
}
