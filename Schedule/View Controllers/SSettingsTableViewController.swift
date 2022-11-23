import UIKit

class SSettingsTableViewController: UITableViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var cachingTooltip: UILabel!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearsSelectionOnViewWillAppear = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let cacheState = SDefaults.isCachingEnabled
        cachingTooltip.text =
            cacheState ? NSLocalizedString("On", comment: "")
            : NSLocalizedString("Off", comment: "")
    }
    
    // MARK: - UITableViewDelegate
    
}
