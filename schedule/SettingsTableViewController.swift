import UIKit


class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var extendedViewSwitch: UISwitch!
    @IBOutlet weak var scrollToCurrentSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        extendedViewSwitch.addTarget(self, action: #selector(onSwitchToggle(sender:)), for: .valueChanged)
        scrollToCurrentSwitch.addTarget(self, action: #selector(onSwitchToggle(sender:)), for: .valueChanged)
    }
    
    @objc func onSwitchToggle(sender: UISwitch) {
        switch (sender.tag) {
        case 1: UserDefaults.standard.set(sender.isOn, forKey: "fullView")
        case 2: UserDefaults.standard.set(sender.isOn, forKey: "swipeWeek") 
        default: return
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section) {
        case 0:
            if indexPath.row == 0 {
                performSegue(withIdentifier: "setupFromSettings", sender: self)
            }
        case 1: return
        case 2: if indexPath.row == 0 { }
        default: return
        }
    }

}
