import UIKit


class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var fullViewSwitch: UISwitch!
    @IBOutlet weak var scrollToTodaySwitch: UISwitch!
    @IBOutlet weak var swipeToChangeSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fullViewSwitch.isOn = UserDefaults.standard.bool(forKey: "FullView")
        fullViewSwitch.addTarget(self, action: #selector(onSwitchToggle(sender:)), for: .valueChanged)

        scrollToTodaySwitch.isOn = UserDefaults.standard.bool(forKey: "ScrollToToday")
        scrollToTodaySwitch.addTarget(self, action: #selector(onSwitchToggle(sender:)), for: .valueChanged)

        swipeToChangeSwitch.isOn = UserDefaults.standard.bool(forKey: "SwipeWeek")
        swipeToChangeSwitch.addTarget(self, action: #selector(onSwitchToggle(sender:)), for: .valueChanged)

        clearsSelectionOnViewWillAppear = true
    }

    @objc func onSwitchToggle(sender: UISwitch) {
        switch (sender.tag) {
        case 1: UserDefaults.standard.set(sender.isOn, forKey: "FullView")
        case 2: UserDefaults.standard.set(sender.isOn, forKey: "ScrollToToday")
        case 3: UserDefaults.standard.set(sender.isOn, forKey: "SwipeWeek")
        default: return
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath.section) {
        case 0: return
        case 1: return
        case 2: if indexPath.row == 0 { }
        default: return
        }
    }


}
