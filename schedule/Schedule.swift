import UIKit


final class ScheduleTableViewController: UIViewController {

    enum TableUpdateAnimationType {
        case hide
        case show
    }

    // MARK: - IBOutlets

    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - IBActions
    
    @IBAction func onBarButtonTap(_ sender: UIBarButtonItem) {
        if !(sender.tag == 2 && weekOffset == 0) {
            switch sender.tag {
                case 1: weekOffset -= 1
                case 2: weekOffset = 0
                case 3: weekOffset += 1
                default: return
            }
            updateModel(for: weekOffset, force: false, programmaticaly: true)
        }
    }

    // MARK: - Private Properties

    private let viewModel = ScheduleViewModel()
    private let refreshControl = UIRefreshControl()
    private let swipeRightRecognizer = UIScreenEdgePanGestureRecognizer()
    private let swipeLeftRecognizer = UIScreenEdgePanGestureRecognizer()
    private var weekOffset: Int = 0
    private var needUpdate: Bool!

    // MARK: - Lifecycle
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(onModalDismiss(_:)), name: Notification.Name("UserSetupModalDismiss"), object: nil)

        tableView.dataSource = viewModel
        tableView.delegate = viewModel
        tableView.register(UINib(nibName: "ScheduleTableViewCell", bundle: nil), forCellReuseIdentifier: "ScheduleTableCell")
        tableView.refreshControl = refreshControl

        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)

        swipeRightRecognizer.addTarget(self, action: #selector(swipeFromEdge(_:)))
        swipeRightRecognizer.edges = .right

        swipeLeftRecognizer.addTarget(self, action: #selector(swipeFromEdge(_:)))
        swipeLeftRecognizer.edges = .left

        viewModel.dataUpdateDidFinishSuccessfully = { [unowned self] in
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
            self.animateTableUpdate(animation: .show)
            self.updateWeekDates(on: self.weekOffset)
        }

        if #available(iOS 13.0, *) {
            navigationController?.view.backgroundColor = .systemGroupedBackground
        } else {
            navigationController?.view.backgroundColor = .groupTableViewBackground
        }

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
                updateModel(for: weekOffset, force: false, programmaticaly: true)
            }
            needUpdate = false
        }
    }

    // MARK: - Private Methods

    @objc private func refresh(_ sender: UIRefreshControl) {
        updateModel(for: weekOffset, force: true, programmaticaly: false)
    }

    @objc private func swipeFromEdge(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        if gestureRecognizer.state == .recognized {
            if gestureRecognizer.edges == .left {
                weekOffset -= 1
            } else if gestureRecognizer.edges == .right {
                weekOffset += 1
            }
            updateModel(for: weekOffset, force: false, programmaticaly: true)
        }
    }
    
    @objc private func onModalDismiss(_ notification: Notification) {
        updateModel(for: weekOffset, force: false, programmaticaly: true)
    }

    private func updateModel(for weekOffset: Int, force: Bool, programmaticaly: Bool) {
        if programmaticaly {
            tableView.setContentOffset(CGPoint(x: 0, y: -refreshControl.frame.size.height), animated: true)
        }
        refreshControl.beginRefreshing()
        animateTableUpdate(animation: .hide)
        viewModel.update(on: weekOffset, force: force)
    }

    private func updateWeekDates(on weekOffset: Int) {
//        navigationItem.prompt = "\(TimeManager.shared.getWeekBoundaries(for: weekOffset))"
    }

    private func animateTableUpdate(animation: TableUpdateAnimationType) {
//        switch animation {
//        case .hide: tableView.isHidden = true
//        case .show: UIView.transition(
//            with: tableView,
//            duration: 0.5,
//            options: [.allowAnimatedContent, .showHideTransitionViews, .transitionCrossDissolve],
//            animations: { [unowned self] in self.tableView.isHidden = false })
//        }
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
        }
    }


}
