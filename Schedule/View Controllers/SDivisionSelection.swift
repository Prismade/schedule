import UIKit

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
    var selectedDivision: Int!
    var needCancelButton = true
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reuseIdentifier = "DivisionTableCell"
        
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
      Task { [weak self] in
        guard let self else { return }
        do {
          let divisions: [SDivision] = try await NetworkWorker().data(from: Oreluniver.divisions)
          self.data = divisions
          await MainActor.run {
            self.refreshControl?.endRefreshing()
            self.tableView.reloadData()
          }
        } catch {
          print(error.localizedDescription)
        }
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
        performSegue(withIdentifier: "ToCourseSelection", sender: self)
    }
    
}
