import UIKit

final class UserSelectionViewController: UIViewController {

    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBAction func onCancelButtonTap(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true) {
            NotificationCenter.default.post(name: Notification.Name("UserSetupModalDismiss"), object: nil, userInfo: nil)
        }
    }

    @IBAction func onStudentButtonTap(_ sender: UIButton) {
        isTeacher = false
        performSegue(withIdentifier: "ToDivisionSelection", sender: self)
    }
    
    @IBAction func onTeacherButtonTap(_ sender: UIButton) {
        isTeacher = true
        performSegue(withIdentifier: "ToDivisionSelection", sender: self)
    }
    
    var needCancelButton = true
    var isTeacher = false

    override func viewDidLoad() {
        super.viewDidLoad()

        if !needCancelButton {
            cancelButton.isEnabled = false
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ?? "" == "ToDivisionSelection" {
            let destination = segue.destination as! DivisionSelectTableViewController
            destination.needCancelButton = needCancelButton
            destination.isTeacher = isTeacher
        }
    }

}
