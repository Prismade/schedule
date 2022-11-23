import UIKit

class SCacheSettingsTableViewController: UITableViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var cacheSwitch: UISwitch!
    
    // MARK: - IBActions
    
    @IBAction func switchChangedState(_ sender: UISwitch) {
        SDefaults.isCachingEnabled = sender.isOn
        if (sender.isOn) {
            numberOfSections = onCachingToggledOnSectionsNumber
            tableView.insertSections(IndexSet(arrayLiteral: 1), with: .fade)
        } else {
            numberOfSections = onCachingToggledOffSectionsNumber
            tableView.deleteSections(IndexSet(arrayLiteral: 1), with: .fade)
        }
    }
    
    // MARK: - Private properties
    
    private let onCachingToggledOnSectionsNumber = 2
    private let onCachingToggledOffSectionsNumber = 1
    private var numberOfSections = 2
    
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
                    do {
                        try SCacheManager.shared.clearCache()
                    } catch {
                        print(error.localizedDescription)
                    }
                default: return
            }
            
            default: return
        }
    }

}
