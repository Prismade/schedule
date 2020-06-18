import UIKit

/**
 Абстрактный класс для построения ViewController'ов для выбора данных
 Необходимо переопределить viewDidLoad(), findMatches(searchString:), updateSearchResults(for:), updateData() и tableView(_: numberOfRowsInSection)
 */
class SSearchableTableViewController: UITableViewController, UISearchBarDelegate, UISearchResultsUpdating {
    
    // MARK: - Public Properties
    
    let searchController = UISearchController(searchResultsController: nil)
    let searchBarPlaceholder = "\(NSLocalizedString("searchPlaceholder", comment: ""))"
    var reuseIdentifier = "SearchableTableCell"
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.placeholder = searchBarPlaceholder
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        definesPresentationContext = true
        clearsSelectionOnViewWillAppear = false
    }
    
    // MARK: - Public Methods
    
    func getFinalCompoundPredicate() -> NSCompoundPredicate {
        let whitespaceCharacterSet = CharacterSet.whitespaces
        let strippedString =
            searchController.searchBar.text!.trimmingCharacters(in: whitespaceCharacterSet)
        let searchItems = strippedString.components(separatedBy: " ") as [String]
        
        let andMatchPredicates: [NSPredicate] = searchItems.map { searchString in
            findMatches(searchString: searchString)
        }
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: andMatchPredicates)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    // MARK: - Private Methods
    
    @objc private func refresh(_ sender: UIRefreshControl) {
        refreshControl?.beginRefreshing()
        updateData()
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
        }
        
        fillCell(&cell!, at: indexPath)
        
        return cell!
    }
    
    // MARK: - Methods for overriding
    
    func updateSearchResults(for searchController: UISearchController) {}
    
    func updateData() {}
    
    func fillCell(_ cell: inout UITableViewCell, at indexPath: IndexPath) {}
    
    func findMatches(searchString: String) -> NSCompoundPredicate {
        return NSCompoundPredicate()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return -1
    }
    
}
