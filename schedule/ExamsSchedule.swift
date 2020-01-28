import UIKit
import Alamofire


class ExamsScheduleTableViewController: UITableViewController {
    
    let reuseIdentifier = "ExamTableCell"
    var data = [Exam]()
    var completionHandler: ((DataResponse<[Exam], AFError>) -> Void)!

    @IBAction func onStopButtonTap(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "ScheduleTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        
        completionHandler = { response in
            switch response.result {
                case .success(let resData): DispatchQueue.main.async {
                    self.data = resData
                    self.refreshControl!.endRefreshing()
                    self.tableView.reloadData()
                }
                case .failure(let err): debugPrint(err.localizedDescription)
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.setContentOffset(CGPoint(x: 0, y: -refreshControl!.frame.size.height), animated: true)
        refreshControl!.beginRefreshing()
        updateData()
    }
    
    @objc func refresh(_ sender: UIRefreshControl) {
        refreshControl!.beginRefreshing()
        updateData()
    }
    
    func updateData() {
        let userId = UserDefaults.standard.integer(forKey: "UserId")
        if (UserDefaults.standard.bool(forKey: "Teacher")) {
            ApiManager.shared.getTeacherExamsSchedule(for: userId, completion: completionHandler)
        } else {
            ApiManager.shared.getStudentExamsSchedule(for: userId, completion: completionHandler)
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ScheduleTableViewCell
        cell.configure(with: data[indexPath.row])

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
