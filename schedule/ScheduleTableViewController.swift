import UIKit


final class ScheduleTableViewController: UIViewController {

    enum TableUpdateAnimationType {
        case hide
        case show
    }

    // MARK: - IBOutlets

    @IBOutlet weak var table: UITableView!
    
    // MARK: - IBActions
    
    @IBAction func onBarButtonTap(_ sender: UIBarButtonItem) {
        switch sender.tag {
        case 1: weekOffset -= 1
        case 2: weekOffset = 0
        case 3: weekOffset += 1
        default: return
        }
        updateModel(for: weekOffset)
    }

    @IBAction func onSettingsButtonTap(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "toSettingsScene", sender: self)
    }

    // MARK: - Private Properties

    private let viewModel = ScheduleViewModel()
    private let refreshControl = UIRefreshControl()
    private let swipeRightRecognizer = UIScreenEdgePanGestureRecognizer()
    private let swipeLeftRecognizer = UIScreenEdgePanGestureRecognizer()
    private var weekOffset: Int = 0

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13, *) {
            if traitCollection.userInterfaceStyle == .dark {
                self.navigationController?.view.backgroundColor = .black
            } else {
                self.navigationController?.view.backgroundColor = .white
            }
        } else {
            self.navigationController?.view.backgroundColor = .white
        }
        
        table.dataSource = viewModel
        table.delegate = viewModel
        table.register(UINib(nibName: "ScheduleTableViewCell", bundle: nil), forCellReuseIdentifier: "ScheduleTableCell")
        table.refreshControl = refreshControl

        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)

        swipeRightRecognizer.addTarget(self, action: #selector(swipeFromEdge(_:)))
        swipeRightRecognizer.edges = .right

        swipeLeftRecognizer.addTarget(self, action: #selector(swipeFromEdge(_:)))
        swipeLeftRecognizer.edges = .left

        viewModel.dataUpdateDidFinishSuccessfully = {
            self.refreshControl.endRefreshing()
            self.table.reloadData()
            self.animateTableUpdate(animation: .show)
            self.updateWeekDates(on: self.weekOffset)
        }

        updateModel(for: weekOffset)
    }

    override func viewWillAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: "swipeWeek") {
            table.addGestureRecognizer(swipeRightRecognizer)
            table.addGestureRecognizer(swipeLeftRecognizer)
        } else {
            table.removeGestureRecognizer(swipeLeftRecognizer)
            table.removeGestureRecognizer(swipeRightRecognizer)
        }
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 12, *) {
            guard previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle else {
                return
            }
            if traitCollection.userInterfaceStyle == .dark {
                self.navigationController?.view.backgroundColor = .black
            } else {
                self.navigationController?.view.backgroundColor = .white
            }
        }
    }

    // MARK: - Private Methods

    @objc private func refresh(_ sender: UIRefreshControl) {
        updateModel(for: weekOffset)
    }

    @objc private func swipeFromEdge(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        if gestureRecognizer.state == .recognized {
            if gestureRecognizer.edges == .left {
                weekOffset -= 1
            } else if gestureRecognizer.edges == .right {
                weekOffset += 1
            }
            updateModel(for: weekOffset)
        }
    }
    
    @objc private func onToolbarButtonTap(_ sender: UIButton) {
        
    }

    private func updateModel(for weekOffset: Int) {
        let defaults = UserDefaults.standard
        let group = defaults.integer(forKey: "group")
        refreshControl.beginRefreshing()
        animateTableUpdate(animation: .hide)
        viewModel.update(for: group, on: weekOffset)
    }

    private func updateWeekDates(on weekOffset: Int) {
//        navigationItem.title = "\(TimeManager.shared.getWeekBoundaries(for: weekOffset))"
        navigationItem.prompt = "\(TimeManager.shared.getWeekBoundaries(for: weekOffset))"
    }

    private func animateTableUpdate(animation: TableUpdateAnimationType) {
        switch animation {
        case .hide: table.isHidden = true
        case .show: UIView.transition(with: table, duration: 0.5, options: [.allowAnimatedContent, .showHideTransitionViews, .transitionCrossDissolve], animations: {
            self.table.isHidden = false
        })
        }
    }


}
