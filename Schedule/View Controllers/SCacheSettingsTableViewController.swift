import UIKit
import PKHUD

class SCacheSettingsTableViewController: UITableViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var cacheSwitch: UISwitch!
    @IBOutlet weak var cacheUserKindTooltop: UILabel!
    
    // MARK: - IBActions
    
    @IBAction func switchChangedState(_ sender: UISwitch) {
        SDefaults.isCachingEnabled = sender.isOn
        if (sender.isOn) {
            numberOfSections = onCachingToggledOnSectionsNumber
            tableView.insertSections(IndexSet(arrayLiteral: 1, 2), with: .fade)
        } else {
            numberOfSections = onCachingToggledOffSectionsNumber
            tableView.deleteSections(IndexSet(arrayLiteral: 1, 2), with: .fade)
        }
    }
    
    // MARK: - Private properties
    
    private let onCachingToggledOnSectionsNumber = 3
    private let onCachingToggledOffSectionsNumber = 1
    private var numberOfSections = 3
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearsSelectionOnViewWillAppear = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        cacheSwitch.isOn = SDefaults.isCachingEnabled
        if (cacheSwitch.isOn) {
            numberOfSections = onCachingToggledOnSectionsNumber
        } else {
            numberOfSections = onCachingToggledOffSectionsNumber
        }
        
        let cacheUserKind = SDefaults.cachingUserKind
        switch cacheUserKind {
            case .student:
                cacheUserKindTooltop.text = NSLocalizedString("Student", comment: "")
            case .teacher:
                cacheUserKindTooltop.text = NSLocalizedString("Teacher", comment: "")
            case .both:
                cacheUserKindTooltop.text = NSLocalizedString("ForAll", comment: "")
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
            case 1: switch indexPath.row {
                case 0:
                    tableView.deselectRow(at: indexPath, animated: true)
                    
                    /*
                     * Due to bug in iOS 12.2 and later this code will produce
                     * a constraint error.
                     */
                    let actionSheets = UIAlertController(
                        title: NSLocalizedString("ChooseUser", comment: ""),
                        message: nil, preferredStyle: .actionSheet)
                    
                    let studentOption = UIAlertAction(
                        title: NSLocalizedString("Student", comment: ""),
                        style: .default) { action in
                            SDefaults.cachingUserKind = .student
                            self.cacheUserKindTooltop.text =
                                NSLocalizedString("Student", comment: "")
                    }
                    actionSheets.addAction(studentOption)
                    
                    let teacherOption = UIAlertAction(
                        title: NSLocalizedString("Teacher", comment: ""),
                        style: .default) { action in
                            SDefaults.cachingUserKind = .teacher
                            self.cacheUserKindTooltop.text =
                                NSLocalizedString("Teacher", comment: "")
                    }
                    actionSheets.addAction(teacherOption)
                    
                    let allOption = UIAlertAction(
                        title: NSLocalizedString("ForAll", comment: ""),
                        style: .default) { action in
                        SDefaults.cachingUserKind = .both
                        self.cacheUserKindTooltop.text =
                            NSLocalizedString("ForAll", comment: "")
                    }
                    actionSheets.addAction(allOption)
                    
                    let cancelAction = UIAlertAction(
                        title: NSLocalizedString("Cancel", comment: ""),
                        style: .cancel, handler: nil)
                    actionSheets.addAction(cancelAction)
                    
                    present(actionSheets, animated: true, completion: nil)
                    
                    /* ======================================================= */
                
                default: return
            }
            
            case 2: switch indexPath.row {
                case 0:
                    tableView.deselectRow(at: indexPath, animated: true)
                    do {
                        try SCacheManager.shared.clearCache()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                           HUD.flash(.success, delay: 1.0)
                        }
                    } catch {
                        print(error.localizedDescription)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                           HUD.flash(.error, delay: 1.0)
                        }
                    }
                default: return
            }
            
            default: return
        }
    }

}
