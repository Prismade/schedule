import UIKit
import Alamofire

final class SDepartmentSelectionTableViewController: SSearchableTableViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    // MARK: - IBActions
    
    @IBAction func onCancelButtonTap(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true) {
            NotificationCenter.default.post(name: Notification.Name("UserSetupModalDismiss"), object: nil, userInfo: nil)
        }
    }
    
    // MARK: - Public Properties
    
    var data = [SDepartment]()
    var filteredData = [SDepartment]()
    var completionHandler: ((DataResponse<[SDepartment], AFError>) -> Void)!
    var division: Int!
    var selectedDepartment: Int!
    var needCancelButton = true
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reuseIdentifier = "DepartmentTableCell"
        
        if !needCancelButton {
            cancelButton.isEnabled = false
        }
        
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
        SApiManager.shared.getDepartments(for: division, completion: completionHandler)
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

        let titleExpression = NSExpression(forKeyPath: SDepartment.ExpressionKeys.title.rawValue)
        let shortExpression = NSExpression(forKeyPath: SDepartment.ExpressionKeys.short.rawValue)
        let searchStringExpression = NSExpression(forConstantValue: searchString)
        
        let titleSearchComparisonPredicate =
            NSComparisonPredicate(leftExpression: titleExpression,
                                  rightExpression: searchStringExpression,
                                  modifier: .direct,
                                  type: .contains,
                                  options: [.caseInsensitive, .diacriticInsensitive])
        let shortSearchComparisonPredicate =
            NSComparisonPredicate(leftExpression: shortExpression,
                                  rightExpression: searchStringExpression,
                                  modifier: .direct,
                                  type: .contains,
                                  options: [.caseInsensitive, .diacriticInsensitive])
        
        searchItemsPredicate.append(titleSearchComparisonPredicate)
        searchItemsPredicate.append(shortSearchComparisonPredicate)
        
        return NSCompoundPredicate(orPredicateWithSubpredicates: searchItemsPredicate)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ?? "" == "ToTeacherSelection" {
            let destination = segue.destination as! STeacherSelectionTableViewController
            destination.department = selectedDepartment
            destination.division = division
            destination.needCancelButton = needCancelButton
        }
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
            selectedDepartment = filteredData[indexPath.row].id
        } else {
            selectedDepartment = data[indexPath.row].id
        }
        
        performSegue(withIdentifier: "ToTeacherSelection", sender: self)
    }
    
}
