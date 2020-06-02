import UIKit
import Alamofire
import SDStateTableView

class SExamsTableViewController: UITableViewController {
    
    // MARK: - Private Properties
    
    private var examsData = [SExam]()
    private var firstSetupFinished = false
    private let reuseIdentifier = "ExamTableCell"
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "SScheduleTableViewCell", bundle: nil),
                           forCellReuseIdentifier: reuseIdentifier)
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        
        (self.tableView as! SDStateTableView).setState(.withButton(
            errorImage: nil, title: NSLocalizedString("NoExams", comment: ""),
            message: NSLocalizedString("NoExamsSoon", comment: ""),
            buttonTitle: NSLocalizedString("Refresh", comment: ""),
            buttonConfig: { button in return }, retryAction: {
                self.tableView.setContentOffset(
                    CGPoint(x: 0, y: -self.refreshControl!.frame.size.height), animated: true)
                self.updateData()
            }))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !firstSetupFinished {
            tableView.setContentOffset(
                CGPoint(x: 0, y: -refreshControl!.frame.size.height), animated: true)
            updateData()
        }
    }
    
    // MARK: - Private Methods
    
    private func updateData() {
        let completionHandler: (DataResponse<[SExam], AFError>) -> Void =
        { [unowned self] response in
            switch response.result {
                case .success(let data): DispatchQueue.main.async {
                    self.examsData = data
                    self.refreshControl?.endRefreshing()
                    
                    if self.examsData.count > 0 {
                        self.tableView.reloadData()
                        (self.tableView as! SDStateTableView).setState(.dataAvailable)
                    } else {
                        (self.tableView as! SDStateTableView).setState(.withButton(
                            errorImage: nil, title: "Пока расписания нет",
                            message: "Экзамены не скоро", buttonTitle: "Обновить",
                            buttonConfig: { button in return }, retryAction: {
                                self.tableView.setContentOffset(
                                    CGPoint(x: 0, y: -self.refreshControl!.frame.size.height),
                                    animated: true)
                                self.updateData()
                        }))
                    }
                }
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
        
        let userKind = SDefaults.defaultUser
        switch userKind {
            case .student:
                guard let id = SDefaults.studentId else { return }
                SApiManager.shared.getStudentExamsSchedule(for: id, completion: completionHandler)
            case .teacher:
                guard let id = SDefaults.teacherId else { return }
                SApiManager.shared.getTeacherExamsSchedule(for: id, completion: completionHandler)
        }
    }
    
    @objc func refresh(_ sender: UIRefreshControl) {
        refreshControl?.beginRefreshing()
        updateData()
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return examsData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: reuseIdentifier,
            for: indexPath) as! SScheduleTableViewCell
        
        let data = examsData[indexPath.row]
        let userKind = SDefaults.defaultUser
        
        switch userKind {
            case .student:
                cell.configure(with: data, cellKind: .student)
            case .teacher:
                cell.configure(with: data, cellKind: .teacher)
        }
        
        return cell
    }
    
}
