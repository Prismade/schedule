import UIKit
import Alamofire


final class DivisionSelectTableViewController: SearchableTableViewController {
    var data = [Division]()
    var filteredData = [Division]()
    var completionHandler: ((DataResponse<[Division], AFError>) -> Void)!
    var selectedDivision: Int!
    var needCancelButton = true
    var isTeacher = false
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBAction func onCancelButtonTap(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true) {
            NotificationCenter.default.post(name: Notification.Name("UserSetupModalDismiss"), object: nil, userInfo: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        reuseIdentifier = "DivisionTableCell"
        
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
        if isTeacher {
            ApiManager.shared.getTeacherDivisions(completion: completionHandler)
        } else {
            ApiManager.shared.getStudentDivisions(completion: completionHandler)
        }
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

        let titleExpression = NSExpression(forKeyPath: Division.ExpressionKeys.title.rawValue)
        let shortExpression = NSExpression(forKeyPath: Division.ExpressionKeys.short.rawValue)
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
            selectedDivision = filteredData[indexPath.row].id
        } else {
            selectedDivision = data[indexPath.row].id
        }
        
        if isTeacher {
            performSegue(withIdentifier: "ToDepartmentSelection", sender: self)
        } else {
            performSegue(withIdentifier: "ToCourseSelection", sender: self)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ?? "" == "ToCourseSelection" {
            let destination = segue.destination as! CourseSelectionTableViewController
            destination.division = selectedDivision
            destination.needCancelButton = needCancelButton
        } else if segue.identifier ?? "" == "ToDepartmentSelection" {
            let destination = segue.destination as! DepartmentSelectionTableViewController
            destination.division = selectedDivision
            destination.needCancelButton = needCancelButton
        }
    }
}
