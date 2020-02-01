import UIKit


final class CachingSettingsTableViewController: UITableViewController {

    @IBOutlet weak var cachingSwitch: UISwitch!
    let onCachingToggledOnSectionsNumber = 2
    let onCachingToggledOffSectionsNumber = 1
    var numberOfSections = 2

    override func viewDidLoad() {
        super.viewDidLoad()
        clearsSelectionOnViewWillAppear = true

        cachingSwitch.isOn = UserDefaults.standard.bool(forKey: "EnableCaching")
        cachingSwitch.addTarget(self, action: #selector(onSwitchToggle(sender:)), for: .valueChanged)

        if (cachingSwitch.isOn) {
            numberOfSections = onCachingToggledOnSectionsNumber
        } else {
            numberOfSections = onCachingToggledOffSectionsNumber
        }
    }

    @objc private func onSwitchToggle(sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "EnableCaching")
        
        if (sender.isOn) {
            numberOfSections = onCachingToggledOnSectionsNumber
            tableView.insertSections(IndexSet(integer: 1), with: .fade)
        } else {
            numberOfSections = onCachingToggledOffSectionsNumber
            tableView.deleteSections(IndexSet(integer: 1), with: .fade)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            do {
                try CacheManager.shared.clear(fileNamePrefixes: [UserDefaults.standard.string(forKey: "StudentCacheFilePrefix")!, UserDefaults.standard.string(forKey: "TeacherCacheFilePrefix")!])
                tableView.deselectRow(at: indexPath, animated: true)
            } catch {}
        }
    }


}
