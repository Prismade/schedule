import UIKit

class SExamsTableViewController: UITableViewController {
  
  // MARK: - Private Properties
  
  private var examsData = [SExam]()
  private var firstSetupFinished = false
  private let reuseIdentifier = "ExamTableCell"
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Экзамены"
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
    
    tableView.register(
        UINib(nibName: "SScheduleTableViewCell", bundle: nil),
        forCellReuseIdentifier: reuseIdentifier)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    if !firstSetupFinished {
      updateData()
    }
  }
  
  // MARK: - Private Methods
  
  private func updateData() {
    guard let id = SDefaults.studentId else { return }
    
    Task { [weak self] in
      guard let self else { return }
      do {
        let exams: [SExam] = try await NetworkWorker().data(from: Oreluniver.exams(group: id))
        self.examsData = exams
        await MainActor.run {
          self.refreshControl?.endRefreshing()
          if self.examsData.count > 0 {
            self.tableView.reloadData()
          }
        }
      } catch {
        print(error.localizedDescription)
      }
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
    cell.configure(with: data)
    return cell
  }
  
}
