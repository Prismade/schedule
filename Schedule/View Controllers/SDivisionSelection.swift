import UIKit
import Alamofire

final class SDivisionSelectionTableViewController: SSearchableTableViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    // MARK: - IBActions
    
    @IBAction func onCancelButtonTap(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true) {
            NotificationCenter.default.post(name: Notification.Name("UserSetupModalDismiss"), object: nil, userInfo: nil)
        }
    }
    
    // MARK: - Public Properties
    
    var data = [SDivision]()
    var filteredData = [SDivision]()
    var completionHandler: ((DataResponse<[SDivision], AFError>) -> Void)!
    var selectedDivision: Int!
    var needCancelButton = true
    var isTeacher = false
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reuseIdentifier = "DivisionTableCell"
        
        if !needCancelButton {
            cancelButton.isEnabled = false
        }
        
        /* Can crash if quickly open and close institute selection and the response comes after
         the vc was closed. Maybe.
        
         Example log message:
         Fatal error: Attempted to read an unowned reference but the object was already deallocated
         2020-06-01 18:40:18.448155+0300 Schedule[12816:1007075] Fatal error: Attempted to read an
         unowned reference but the object was already deallocated
         */
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
        if isTeacher {
            SApiManager.shared.getTeacherDivisions(completion: completionHandler)
        } else {
            SApiManager.shared.getStudentDivisions(completion: completionHandler)
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

        let titleExpression = NSExpression(forKeyPath: SDivision.ExpressionKeys.title.rawValue)
        let shortExpression = NSExpression(forKeyPath: SDivision.ExpressionKeys.short.rawValue)
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
        if segue.identifier ?? "" == "ToCourseSelection" {
            let destination = segue.destination as! SCourseSelectionTableViewController
            destination.division = selectedDivision
            destination.needCancelButton = needCancelButton
        } else if segue.identifier ?? "" == "ToDepartmentSelection" {
            let destination = segue.destination as! SDepartmentSelectionTableViewController
            destination.division = selectedDivision
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
    
}
