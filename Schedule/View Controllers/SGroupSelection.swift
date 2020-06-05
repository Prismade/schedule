import UIKit
import Alamofire

final class SGroupSelectionTableViewController: SSearchableTableViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    // MARK: - IBActions
    
    @IBAction func onFinishButtonTap(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true) {
            NotificationCenter.default.post(name: Notification.Name("UserSetupModalDismiss"), object: nil, userInfo: nil)
        }
    }
    
    // MARK: - Public Properties
    
    var division: Int!
    var course: Int!
    var selectedGroup: Int!
    var needCancelButton = true
    var data = [SGroup]()
    var filteredData = [SGroup]()
    var completionHandler: ((DataResponse<[SGroup], AFError>) -> Void)!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reuseIdentifier = "DivisionTableCell"
        completionHandler = { [unowned self] response in
            switch response.result {
                case .success(let resData): DispatchQueue.main.async {
                    self.data = resData
                    self.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                }
                case .failure(let err): debugPrint(err.localizedDescription)
            }
        }
        
        if !needCancelButton {
            cancelButton.isEnabled = false
        }
        
        updateData()
    }
    
    // MARK: - Public Methods
    
    override func updateSearchResults(for searchController: UISearchController) {
        let searchResults = data
        let finalCompoundPredicate = getFinalCompoundPredicate()
        filteredData = searchResults.filter { finalCompoundPredicate.evaluate(with: $0) }
        tableView.reloadData()
    }
    
    override func updateData() {
        SApiManager.shared.getGroups(for: course, at: division, completion: completionHandler)
    }
    
    override func fillCell(_ cell: inout UITableViewCell, at indexPath: IndexPath) {
        if isFiltering {
            cell.textLabel?.text = filteredData[indexPath.row].title
        } else {
            cell.textLabel?.text = data[indexPath.row].title
        }
    }
    
    override func findMatches(searchString: String) -> NSCompoundPredicate {
        var searchItemsPredicate = [NSPredicate]()
        
        let titleExpression = NSExpression(forKeyPath: SGroup.ExpressionKeys.title.rawValue)
        let codeExpression = NSExpression(forKeyPath: SGroup.ExpressionKeys.code.rawValue)
        let levelExpression = NSExpression(forKeyPath: SGroup.ExpressionKeys.level.rawValue)
        
        let searchStringExpression = NSExpression(forConstantValue: searchString)
        
        let titleSearchComparisonPredicate =
            NSComparisonPredicate(leftExpression: titleExpression,
                                  rightExpression: searchStringExpression,
                                  modifier: .direct,
                                  type: .contains,
                                  options: [.caseInsensitive, .diacriticInsensitive])
        let codeSearchComparisonPredicate =
            NSComparisonPredicate(leftExpression: codeExpression,
                                  rightExpression: searchStringExpression,
                                  modifier: .direct,
                                  type: .contains,
                                  options: [.caseInsensitive, .diacriticInsensitive])
        let levelSearchComparisonPredicate =
            NSComparisonPredicate(leftExpression: levelExpression,
                                  rightExpression: searchStringExpression,
                                  modifier: .direct,
                                  type: .contains,
                                  options: [.caseInsensitive, .diacriticInsensitive])
        
        searchItemsPredicate.append(titleSearchComparisonPredicate)
        searchItemsPredicate.append(codeSearchComparisonPredicate)
        searchItemsPredicate.append(levelSearchComparisonPredicate)
        
        return NSCompoundPredicate(orPredicateWithSubpredicates: searchItemsPredicate)
    }
    
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredData.count
        } else {
            return data.count
        }
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isFiltering {
            selectedGroup = filteredData[indexPath.row].id
        } else {
            selectedGroup = data[indexPath.row].id
        }
        
        navigationController?.dismiss(animated: true) {
            NotificationCenter.default.post(name: Notification.Name("StudentSetupModalDismiss"), object: nil, userInfo: ["UserId": self.selectedGroup!])
        }
    }
    
}
