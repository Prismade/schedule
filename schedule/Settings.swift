import UIKit


final class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var scrollToTodaySwitch: UISwitch!
    @IBOutlet weak var swipeToChangeSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollToTodaySwitch.isOn = UserDefaults.standard.bool(forKey: "ScrollOnStart")
        scrollToTodaySwitch.addTarget(self, action: #selector(onSwitchToggle(sender:)), for: .valueChanged)
        swipeToChangeSwitch.isOn = UserDefaults.standard.bool(forKey: "SwipeToSwitch")
        swipeToChangeSwitch.addTarget(self, action: #selector(onSwitchToggle(sender:)), for: .valueChanged)
        clearsSelectionOnViewWillAppear = true
    }
    
    @objc func onSwitchToggle(sender: UISwitch) {
        switch (sender.tag) {
            case 2: UserDefaults.standard.set(sender.isOn, forKey: "ScrollOnStart")
            case 3: UserDefaults.standard.set(sender.isOn, forKey: "SwipeWeek")
            default: return
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }


}
