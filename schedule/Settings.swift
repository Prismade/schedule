import UIKit
import EventKit
import EventKitUI


final class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var scrollToTodaySwitch: UISwitch!
    @IBOutlet weak var swipeToChangeSwitch: UISwitch!
    
    private lazy var calendarSelectionViewController = UINavigationController()
    
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
        
        if indexPath.section == 2 && indexPath.row == 0 {
            exportToCalendar()
        }
    }
    
    func exportToCalendar() {
        switch ExportManager.shared.authStatus() {
        case .notDetermined:
            ExportManager.shared.requestPermission { [unowned self] authorized, error in
                if authorized {
                    DispatchQueue.main.async {
                        self.chooseCalendar()
                    }
                }
            }
        case .authorized:
            chooseCalendar()
        case .denied:
            let alert = UIAlertController(title: "Нет разрешения", message: "Для экспорта данных в календарь нужно разрешение. Перейдите в настройки и включите разрешение доступа к календарю.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        default: return
        }
    }
    
    func chooseCalendar() {
        let ccvc = EKCalendarChooser(selectionStyle: .single, displayStyle: .writableCalendarsOnly, eventStore: ExportManager.shared.eventStore)
        ccvc.delegate = self
        ccvc.showsDoneButton = true
        ccvc.showsCancelButton = true

        calendarSelectionViewController.pushViewController(ccvc, animated: false)
        present(calendarSelectionViewController, animated: true, completion: nil)
    }


}


extension SettingsTableViewController: EKCalendarChooserDelegate {

    func calendarChooserDidFinish(_ calendarChooser: EKCalendarChooser) {
        if let selectedCalendar = calendarChooser.selectedCalendars.first {
            do {
                try ExportManager.shared.export(into: selectedCalendar)
            } catch let error {
                print(error.localizedDescription)
            }
        }
        calendarSelectionViewController.dismiss(animated: true)
        
    }
    
    func calendarChooserDidCancel(_ calendarChooser: EKCalendarChooser) {
        calendarSelectionViewController.dismiss(animated: true)
    }
}
