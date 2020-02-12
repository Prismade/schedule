import UIKit


final class ScheduleTableViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - IBActions
    
    @IBAction func onBarButtonTap(_ sender: UIBarButtonItem) {
        var weekOffset = ScheduleManager.shared.getWeekOffset()
        if !(sender.tag == 2 && weekOffset == 0) {
            switch sender.tag {
                case 1: weekOffset -= 1
                case 2: weekOffset = 0
                case 3: weekOffset += 1
                default: return
            }
            updateWeekOffset(weekOffset)
        }
    }

    // MARK: - Private Properties

    private let refreshControl = UIRefreshControl()
    private let swipeRightRecognizer = UIScreenEdgePanGestureRecognizer()
    private let swipeLeftRecognizer = UIScreenEdgePanGestureRecognizer()
    private var needUpdate: Bool!
    private var didPerformScrollOnStart = false
    private var selectedCell: IndexPath!

    // MARK: - Lifecycle
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(onModalDismiss(_:)), name: Notification.Name("UserSetupModalDismiss"), object: nil)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "ScheduleTableViewCell", bundle: nil), forCellReuseIdentifier: "ScheduleTableCell")
        tableView.refreshControl = refreshControl

        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)

        swipeRightRecognizer.addTarget(self, action: #selector(swipeFromEdge(_:)))
        swipeRightRecognizer.edges = .right

        swipeLeftRecognizer.addTarget(self, action: #selector(swipeFromEdge(_:)))
        swipeLeftRecognizer.edges = .left

        needUpdate = true
    }

    override func viewWillAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: "SwipeToSwitch") {
            tableView.addGestureRecognizer(swipeRightRecognizer)
            tableView.addGestureRecognizer(swipeLeftRecognizer)
        } else {
            tableView.removeGestureRecognizer(swipeLeftRecognizer)
            tableView.removeGestureRecognizer(swipeRightRecognizer)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        if needUpdate {
            if UserDefaults.standard.object(forKey: "UserId") == nil {
                performSegue(withIdentifier: "ToSetupDialogFromSchedule", sender: self)
            } else {
                updateModel(force: false, programmaticaly: true)
            }
            needUpdate = false
        }
    }

    // MARK: - Private Methods

    @objc private func refresh(_ sender: UIRefreshControl) {
        updateModel(force: true, programmaticaly: false)
    }

    @objc private func swipeFromEdge(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        if gestureRecognizer.state == .recognized {
            var weekOffset = ScheduleManager.shared.getWeekOffset()
            if gestureRecognizer.edges == .left {
                weekOffset -= 1
            } else if gestureRecognizer.edges == .right {
                weekOffset += 1
            }
            updateWeekOffset(weekOffset)
        }
    }
    
    @objc private func onModalDismiss(_ notification: Notification) {
        updateModel(force: false, programmaticaly: true)
    }

    private func updateModel(force: Bool, programmaticaly: Bool) {
        if programmaticaly {
            tableView.setContentOffset(CGPoint(x: 0, y: -refreshControl.frame.size.height), animated: true)
        }
        refreshControl.beginRefreshing()
        ScheduleManager.shared.update(force: force) { [unowned self] error in
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    private func updateWeekOffset(_ newValue: Int) {
        refreshControl.beginRefreshing()
        ScheduleManager.shared.setWeekOffset(newValue) { [unowned self] error in
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ?? "" == "ToSetupDialogFromSchedule" {
            let destination = segue.destination as! UINavigationController
            let vc = destination.topViewController! as! UserSelectionViewController
            vc.needCancelButton = false

            if #available(iOS 13.0, *) {
                vc.isModalInPresentation = true
            }
        } else if segue.identifier ?? "" == "ToScheduleDetails" {
            let destination = segue.destination as! ScheduleDetailsViewController
            destination.day = selectedCell.section
            destination.lesson = selectedCell.row
        }
    }


}


extension ScheduleTableViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return ScheduleManager.shared.daysCount()
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ScheduleManager.shared.title(for: section)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let number = ScheduleManager.shared.lessonsCount(for: section)
        if number == 0 {
            return 1 // for a cell, that tells there are no lessons
        } else {
            return number
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleTableCell", for: indexPath) as! ScheduleTableViewCell
        let cellType: CellType!
        if UserDefaults.standard.bool(forKey: "Teacher") {
            cellType = .teacher
        } else {
            cellType = .student
        }
        cell.configure(with: ScheduleManager.shared.lesson(at: (indexPath.section, indexPath.row)), cellType: cellType)
        cell.selectionStyle = .none
        return cell
    }
}


extension ScheduleTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let lastVisibleIndexPath = tableView.indexPathsForVisibleRows?.last {
            let defaults = UserDefaults.standard
            if indexPath == lastVisibleIndexPath &&
                !didPerformScrollOnStart &&
                defaults.bool(forKey: "ScrollOnStart") {
                tableView.scrollToRow(
                    at: IndexPath(
                        row: 0,
                        section: TimeManager.shared.getCurrentWeekDay()),
                    at: .top, animated: true)
                didPerformScrollOnStart = true
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let _ = ScheduleManager.shared.lesson(at: (indexPath.section, indexPath.row)) else { return }
        selectedCell = indexPath
        performSegue(withIdentifier: "ToScheduleDetails", sender: self)
    }
}
