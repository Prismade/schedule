import UIKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {

        if UserDefaults.standard.object(forKey: "EnableCaching") == nil {
            UserDefaults.standard.set(false, forKey: "EnableCaching")
        }
        
        if UserDefaults.standard.object(forKey: "RequestInterval") == nil {
            UserDefaults.standard.set(2, forKey: "RequestInterval")
        }
        
        if UserDefaults.standard.object(forKey: "ScrollOnStart") == nil {
            UserDefaults.standard.set(false, forKey: "ScrollOnStart")
        }
        
        if UserDefaults.standard.object(forKey: "SwipeToSwitch") == nil {
            UserDefaults.standard.set(true, forKey: "SwipeToSwitch")
        }
        
        if UserDefaults.standard.object(forKey: "StudentCacheFilePrefix") == nil {
            UserDefaults.standard.set("stud", forKey: "StudentCacheFilePrefix")
        }
        
        if UserDefaults.standard.object(forKey: "TeacherCacheFilePrefix") == nil {
            UserDefaults.standard.set("teach", forKey: "TeacherCacheFilePrefix")
        }
        
        if UserDefaults.standard.object(forKey: "BuildingsCacheFilePrefix") == nil {
            UserDefaults.standard.set("buildings", forKey: "BuildingsCacheFilePrefix")
        }
        
        if UserDefaults.standard.object(forKey: "EmployeeCacheFilePrefix") == nil {
            UserDefaults.standard.set("empl", forKey: "EmployeeCacheFilePrefix")
        }
        
        return true
    }

    // MARK: - UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }


}

