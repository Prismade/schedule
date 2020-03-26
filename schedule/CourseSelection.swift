import UIKit
import Alamofire


final class CourseSelectionTableViewController: UITableViewController {
    let reuseIdentifier = "CourseTableCell"
    var needCancelButton = true
    var division: Int!
    var selectedCourse: Int!
    var data = [Course]()

    @IBOutlet weak var cancelButton: UIBarButtonItem!

    @IBAction func onCancelButtonTap(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true) {
            NotificationCenter.default.post(name: Notification.Name("UserSetupModalDismiss"), object: nil, userInfo: nil)
        }
    }

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
    
    @objc func refresh(_ sender: UIRefreshControl) {
        refreshControl?.beginRefreshing()
        updateData()
    }
    
    func updateData() {
        ApiManager.shared.getCourses(for: division) { response in
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

    // MARK: - Table view data source

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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCourse = data[indexPath.row].course
        performSegue(withIdentifier: "ToGroupSelection", sender: self)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ?? "" == "ToGroupSelection" {
            let destination = segue.destination as! GroupSelectionTableViewController
            destination.division = division
            destination.course = selectedCourse
            destination.needCancelButton = needCancelButton
        }
    }

}
