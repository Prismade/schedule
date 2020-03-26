import UIKit
import Alamofire


final class DepartmentSelectionTableViewController: SearchableTableViewController {

    var data = [Department]()
    var filteredData = [Department]()
    var completionHandler: ((DataResponse<[Department], AFError>) -> Void)!
    var division: Int!
    var selectedDepartment: Int!
    var needCancelButton = true
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBAction func onCancelButtonTap(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true) {
            NotificationCenter.default.post(name: Notification.Name("UserSetupModalDismiss"), object: nil, userInfo: nil)
        }
    }

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
    
    override func updateSearchResults(for searchController: UISearchController) {
        let searchResults = data
        let finalCompoundPredicate = getFinalCompoundPredicate()
        filteredData = searchResults.filter { finalCompoundPredicate.evaluate(with: $0) }
        tableView.reloadData()
    }
    
    override func updateData() {
        ApiManager.shared.getDepartments(for: division, completion: completionHandler)
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

        let titleExpression = NSExpression(forKeyPath: Department.ExpressionKeys.title.rawValue)
        let shortExpression = NSExpression(forKeyPath: Department.ExpressionKeys.short.rawValue)
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredData.count
        } else {
            return data.count
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isFiltering {
            selectedDepartment = filteredData[indexPath.row].id
        } else {
            selectedDepartment = data[indexPath.row].id
        }
        
        performSegue(withIdentifier: "ToTeacherSelection", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ?? "" == "ToTeacherSelection" {
            let destination = segue.destination as! TeacherSelectionTableViewController
            destination.department = selectedDepartment
            destination.division = division
            destination.needCancelButton = needCancelButton
        }
    }

}
