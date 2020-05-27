import UIKit

class SSettingsTableViewController: UITableViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var defaultScheduleTooltip: UILabel!
    @IBOutlet weak var cachingTooltip: UILabel!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearsSelectionOnViewWillAppear = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let defaultSchedule = SDefaults.defaultUser
        switch defaultSchedule {
            case .student:
                defaultScheduleTooltip.text = NSLocalizedString("Student", comment: "")
            case .teacher:
                defaultScheduleTooltip.text = NSLocalizedString("Teacher", comment: "")
        }
        
        let cacheState = SDefaults.isCachingEnabled
        cachingTooltip.text =
            cacheState ? NSLocalizedString("On", comment: "")
            : NSLocalizedString("Off", comment: "")
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
            case 0: switch indexPath.row {
                case 0:
                    tableView.deselectRow(at: indexPath, animated: true)
                    let actionSheets = UIAlertController(
                        title: NSLocalizedString("ChooseUser", comment: ""),
                        message: NSLocalizedString("ChooseUserDescription", comment: ""),
                        preferredStyle: .actionSheet)
                    
                    let studentOption = UIAlertAction(
                        title: NSLocalizedString("Student", comment: ""),
                        style: .default) { action in
                            SDefaults.defaultUser = .student
                            self.defaultScheduleTooltip.text =
                                NSLocalizedString("Student", comment: "")
                    }
                    actionSheets.addAction(studentOption)
                    
                    let teacherOption = UIAlertAction(
                        title: NSLocalizedString("Teacher", comment: ""),
                        style: .default) { action in
                            SDefaults.defaultUser = .teacher
                            self.defaultScheduleTooltip.text =
                                NSLocalizedString("Teacher", comment: "")
                    }
                    actionSheets.addAction(teacherOption)
                    
                    let cancelAction = UIAlertAction(
                        title: NSLocalizedString("Cancel", comment: ""),
                        style: .cancel, handler: nil)
                    actionSheets.addAction(cancelAction)
                    
                    present(actionSheets, animated: true, completion: nil)
                
                default: return
            }
            
            default: return
        }
    }
    
}
