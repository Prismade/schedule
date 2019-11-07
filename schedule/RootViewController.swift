import UIKit

class RootViewController: UIViewController {

    @IBOutlet weak var container: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        if defaults.bool(forKey: "firstRun") {
            let childViewController = storyboard.instantiateViewController(withIdentifier: "Setup")
            addChild(childViewController)
            view = childViewController.view
        } else {
            let childViewController = storyboard.instantiateViewController(withIdentifier: "ScheduleNavigation")
            addChild(childViewController)
            view = childViewController.view
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension RootViewController: UITabBarControllerDelegate {
    
}
