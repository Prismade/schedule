import UIKit

class SetupViewController: UIViewController {

    @IBOutlet weak var studentButton: UIButton!
    @IBOutlet weak var teacherButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        studentButton.addTarget(self, action: #selector(buttonTaped(sender:)), for: .touchUpInside)
        teacherButton.addTarget(self, action: #selector(buttonTaped(sender:)), for: .touchUpInside)
    }
    
    @objc func buttonTaped(sender: UIButton) {
        switch sender.tag {
        case 1: UserDefaults.standard.set(1, forKey: "UserType")
        case 2: UserDefaults.standard.set(2, forKey: "UserType")
        default: return
        }
        performSegue(withIdentifier: "presentFromSetup", sender: self)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }

}
