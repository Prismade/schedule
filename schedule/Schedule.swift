import UIKit


final class ScheduleTableViewController: UIViewController {
    
    enum ScheduleType {
        case my
        case other
    }

    // MARK: - IBOutlets

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
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

    @IBAction func onSegmentControlTap(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            scheduleType = .my
            updateModel(force: false, programmaticaly: true)
        } else if sender.selectedSegmentIndex == 1 {
            scheduleType = .other
            performSegue(withIdentifier: "ToSetupDialogFromSchedule", sender: self)
        }
    }
    // MARK: - Private Properties

    private let refreshControl = UIRefreshControl()
    private let swipeRightRecognizer = UISwipeGestureRecognizer()
    private let swipeLeftRecognizer = UISwipeGestureRecognizer()
    private var needUpdate: Bool!
    private var didPerformScrollOnStart = false
    private var selectedCell: IndexPath!
    private var scheduleType: ScheduleType = .my
    private var tempUserInfo = [String : Int]()

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
        tableView.rowHeight = UITableView.automaticDimension

        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)

        swipeRightRecognizer.addTarget(self, action: #selector(swipeFromEdge(_:)))
        swipeRightRecognizer.direction = .right
        tableView.addGestureRecognizer(swipeRightRecognizer)
        
        swipeLeftRecognizer.addTarget(self, action: #selector(swipeFromEdge(_:)))
        swipeLeftRecognizer.direction = .left
        tableView.addGestureRecognizer(swipeLeftRecognizer)

        needUpdate = true
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

    @objc private func swipeFromEdge(_ gestureRecognizer: UISwipeGestureRecognizer) {
        if gestureRecognizer.state == .recognized {
            var weekOffset = ScheduleManager.shared.getWeekOffset()
            if gestureRecognizer.direction == .right {
                weekOffset -= 1
            } else if gestureRecognizer.direction == .left {
                weekOffset += 1
            }
            updateWeekOffset(weekOffset)
        }
    }
    
    @objc private func onModalDismiss(_ notification: Notification) {
        if let result = notification.userInfo {
            if scheduleType == .my {
                UserDefaults.standard.set(result["UserId"], forKey: "UserId")
                if (result as! [String : Int])["Teacher"] == 1 {
                    UserDefaults.standard.set(true, forKey: "Teacher")
                } else {
                    UserDefaults.standard.set(false, forKey: "Teacher")
                }
            } else if scheduleType == .other {
                tempUserInfo = result as! [String : Int]
            }
            updateModel(force: false, programmaticaly: true)
        } else {
            scheduleType = .my
            segmentedControl.selectedSegmentIndex = 0
        }
    }

    private func updateModel(force: Bool, programmaticaly: Bool) {
        if programmaticaly {
            tableView.setContentOffset(CGPoint(x: 0, y: -refreshControl.frame.size.height), animated: true)
        }
        refreshControl.beginRefreshing()
        let completionHandler: (Error?) -> Void = { [unowned self] error in
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
        }
        if scheduleType == .my {
            let updateType: UpdateType = force ? .force : .normal
            ScheduleManager.shared.update(for: UserDefaults.standard.integer(forKey: "UserId"), isTeacher: UserDefaults.standard.bool(forKey: "Teacher"), updateType: updateType, completion: completionHandler)
        } else if scheduleType == .other {
            ScheduleManager.shared.update(for: tempUserInfo["UserId"]!, isTeacher: tempUserInfo["Teacher"] == 1 ? true : false, updateType: .nonCaching, completion: completionHandler)
        }
        
    }
    
    private func updateWeekOffset(_ newValue: Int) {
        tableView.setContentOffset(CGPoint(x: 0, y: -refreshControl.frame.size.height), animated: true)
        refreshControl.beginRefreshing()
        
        let completionHandler: (Error?) -> Void = { [unowned self] error in
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
        }
        if scheduleType == .my {
            ScheduleManager.shared.setWeekOffset(newValue, for: UserDefaults.standard.integer(forKey: "UserId"), isTeacher: UserDefaults.standard.bool(forKey: "Teacher"), updateType: .normal, completion: completionHandler)
        } else if scheduleType == .other {
            ScheduleManager.shared.update(for: tempUserInfo["UserId"]!, isTeacher: tempUserInfo["Teacher"] == 1 ? true : false, updateType: .nonCaching, completion: completionHandler)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ?? "" == "ToSetupDialogFromSchedule" {
            let destination = segue.destination as! UINavigationController
            let vc = destination.topViewController! as! UserSelectionViewController
            
            if scheduleType == .my {
                vc.needCancelButton = false

                if #available(iOS 13.0, *) {
                    vc.isModalInPresentation = true
                }
            } else if scheduleType == .other {
                vc.needCancelButton = true
                if #available(iOS 13.0, *) {
                    vc.navigationController?.presentationController?.delegate = self
                }
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
                var weekDay = TimeManager.shared.getCurrentWeekDay()
                if weekDay == 1 {
                    weekDay = 0
                } else {
                    weekDay -= 2
                }
                tableView.scrollToRow(
                    at: IndexPath(
                        row: 0,
                        section: weekDay),
                    at: .top, animated: true)
                didPerformScrollOnStart = true
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let _ = ScheduleManager.shared.lesson(at: (indexPath.section, indexPath.row)) else { return }
        selectedCell = indexPath
        performSegue(withIdentifier: "ToScheduleDetails", sender: self)
    }
}

@available(iOS 13.0, *)
extension ScheduleTableViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        scheduleType = .my
        segmentedControl.selectedSegmentIndex = 0
    }
}
