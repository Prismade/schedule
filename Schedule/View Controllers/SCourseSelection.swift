import UIKit
import Alamofire

final class SCourseSelectionTableViewController: UITableViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    // MARK: - IBActions
    
    @IBAction func onCancelButtonTap(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true) {
            NotificationCenter.default.post(name: Notification.Name("UserSetupModalDismiss"), object: nil, userInfo: nil)
        }
    }
    
    // MARK: - Public Properties
    
    let reuseIdentifier = "CourseTableCell"
    var needCancelButton = true
    var division: Int!
    var selectedCourse: Int!
    var data = [SCourse]()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        
        if !needCancelButton {
            cancelButton.isEnabled = false
        }
        
        clearsSelectionOnViewWillAppear = false
        
        updateData()
    }
    
    // MARK: - Public Methods
    
    @objc func refresh(_ sender: UIRefreshControl) {
        refreshControl?.beginRefreshing()
        updateData()
    }
    
    func updateData() {
        SApiManager.shared.getCourses(for: division) { response in
            switch response.result {
                case .success(let data):
                    DispatchQueue.main.async {
                        self.data = data
                        self.refreshControl?.endRefreshing()
                        self.tableView.reloadData()
                }
                case .failure(let error):
                    debugPrint(error.localizedDescription)
            }
            
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ?? "" == "ToGroupSelection" {
            let destination = segue.destination as! SGroupSelectionTableViewController
            destination.division = division
            destination.course = selectedCourse
            destination.needCancelButton = needCancelButton
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
        }
        cell!.textLabel?.text = String(data[indexPath.row].course)
        
        return cell!
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCourse = data[indexPath.row].course
        performSegue(withIdentifier: "ToGroupSelection", sender: self)
    }
    
}
