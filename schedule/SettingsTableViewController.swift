import UIKit


class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var fullViewSwitch: UISwitch!
    @IBOutlet weak var scrollToTodaySwitch: UISwitch!
    @IBOutlet weak var swipeToChangeSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fullViewSwitch.isOn = UserDefaults.standard.bool(forKey: "fullView")
        fullViewSwitch.addTarget(self, action: #selector(onSwitchToggle(sender:)), for: .valueChanged)

        scrollToTodaySwitch.isOn = UserDefaults.standard.bool(forKey: "scrollToToday")
        scrollToTodaySwitch.addTarget(self, action: #selector(onSwitchToggle(sender:)), for: .valueChanged)

        swipeToChangeSwitch.isOn = UserDefaults.standard.bool(forKey: "swipeWeek")
        swipeToChangeSwitch.addTarget(self, action: #selector(onSwitchToggle(sender:)), for: .valueChanged)

        clearsSelectionOnViewWillAppear = true
    }

    @objc func onSwitchToggle(sender: UISwitch) {
        switch (sender.tag) {
        case 1: UserDefaults.standard.set(sender.isOn, forKey: "fullView")
        case 2: UserDefaults.standard.set(sender.isOn, forKey: "scrollToToday")
        case 3: UserDefaults.standard.set(sender.isOn, forKey: "swipeWeek")
        default: return
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section) {
        case 0:
            if indexPath.row == 0 {
//                let sb = UIStoryboard(name: "Main", bundle: nil)
//                let vc = sb.instantiateViewController(withIdentifier: "ClientSetupNavigation")
//                let viewController = ChoiceViewController()
//                vc.setViewSettings(for: nil, to: .step0)
//                viewController.modalPresentationStyle = .fullScreen
//                present(vc, animated: true, completion: nil)
                performSegue(withIdentifier: "setupFromSettings", sender: self)
            }
        case 1: return
        case 2: if indexPath.row == 0 { }
        default: return
        }
    }


}
