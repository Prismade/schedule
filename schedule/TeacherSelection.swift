import UIKit
import Alamofire


final class TeacherSelectionTableViewController: SearchableTableViewController {
    
    var division: Int!
    var department: Int!
    var selectedTeacher: Int!
    var needCancelButton: Bool!
    var data = [Teacher]()
    var filteredData = [Teacher]()
    var completionHandler: ((DataResponse<[Teacher], AFError>) -> Void)!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!

    @IBAction func onCancelButtonTap(_ sender: UIBarButtonItem) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reuseIdentifier = "TeacherTableCell"
        
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
        ApiManager.shared.getTeachers(for: department, at: division, completion: completionHandler)
    }
    
    override func fillCell(_ cell: inout UITableViewCell, at indexPath: IndexPath) {
        if isFiltering {
            cell.textLabel?.text = filteredData[indexPath.row].name
        } else {
            cell.textLabel?.text = data[indexPath.row].name
        }
    }
    
    override func findMatches(searchString: String) -> NSCompoundPredicate {
        var searchItemsPredicate = [NSPredicate]()

        let lastNameExpression = NSExpression(forKeyPath: Teacher.ExpressionKeys.lastName.rawValue)
        let firstNameExpression = NSExpression(forKeyPath: Teacher.ExpressionKeys.firstName.rawValue)
        let patronymicExpression = NSExpression(forKeyPath: Teacher.ExpressionKeys.patronymic.rawValue)
        let searchStringExpression = NSExpression(forConstantValue: searchString)
        
        let lastNameSearchComparisonPredicate =
            NSComparisonPredicate(leftExpression: lastNameExpression,
                                  rightExpression: searchStringExpression,
                                  modifier: .direct,
                                  type: .contains,
                                  options: [.caseInsensitive, .diacriticInsensitive])
        let firstNameSearchComparisonPredicate =
            NSComparisonPredicate(leftExpression: firstNameExpression,
                                  rightExpression: searchStringExpression,
                                  modifier: .direct,
                                  type: .contains,
                                  options: [.caseInsensitive, .diacriticInsensitive])
        let patronymicSearchComparisonPredicate =
        NSComparisonPredicate(leftExpression: patronymicExpression,
                              rightExpression: searchStringExpression,
                              modifier: .direct,
                              type: .contains,
                              options: [.caseInsensitive, .diacriticInsensitive])
        
        searchItemsPredicate.append(lastNameSearchComparisonPredicate)
        searchItemsPredicate.append(firstNameSearchComparisonPredicate)
        searchItemsPredicate.append(patronymicSearchComparisonPredicate)
        
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
            selectedTeacher = filteredData[indexPath.row].id
        } else {
            selectedTeacher = data[indexPath.row].id
        }
        
        UserDefaults.standard.set(true, forKey: "Teacher")
        UserDefaults.standard.set(selectedTeacher, forKey: "UserId")
        
        navigationController?.dismiss(animated: true) {
            NotificationCenter.default.post(name: Notification.Name("UserSetupModalDismiss"), object: nil, userInfo: nil)
        }
    }


}
