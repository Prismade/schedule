import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        if UserDefaults.standard.object(forKey: "EnableCaching") == nil {
            UserDefaults.standard.set(false, forKey: "EnableCaching")
        }
        
        if UserDefaults.standard.object(forKey: "CacheExpirationPeriod") == nil {
            UserDefaults.standard.set(604800, forKey: "CacheExpirationPeriod")
        }
        
        if UserDefaults.standard.object(forKey: "ExtendedView") == nil {
            UserDefaults.standard.set(false, forKey: "ExtendedView")
        }
        
        if UserDefaults.standard.object(forKey: "ScrollOnStart") == nil {
            UserDefaults.standard.set(false, forKey: "ScrollOnStart")
        }
        
        if UserDefaults.standard.object(forKey: "SwipeToSwitch") == nil {
            UserDefaults.standard.set(true, forKey: "SwipeToSwitch")
        }
        
        return true
    }

    // MARK: - UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }


}

