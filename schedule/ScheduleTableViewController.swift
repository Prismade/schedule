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
        if !(sender.tag == 2 && weekOffset == 0) {
            switch sender.tag {
                case 1: weekOffset -= 1
                case 2: weekOffset = 0
                case 3: weekOffset += 1
                default: return
            }
            updateModel(for: weekOffset)
        }
    }

    @IBAction func onSettingsButtonTap(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "ToMainSettings", sender: self)
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

        table.dataSource = viewModel
        table.delegate = viewModel
        table.register(UINib(nibName: "ScheduleTableViewCell", bundle: nil), forCellReuseIdentifier: "ScheduleTableCell")
        table.refreshControl = refreshControl

        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)

        swipeRightRecognizer.addTarget(self, action: #selector(swipeFromEdge(_:)))
        swipeRightRecognizer.edges = .right

        swipeLeftRecognizer.addTarget(self, action: #selector(swipeFromEdge(_:)))
        swipeLeftRecognizer.edges = .left

        viewModel.dataUpdateDidFinishSuccessfully = { [unowned self] in
            self.refreshControl.endRefreshing()
            self.table.reloadData()
            self.animateTableUpdate(animation: .show)
            self.updateWeekDates(on: self.weekOffset)
        }

        if #available(iOS 13.0, *) {
            self.navigationController?.view.backgroundColor = .systemGroupedBackground
        } else {
            self.navigationController?.view.backgroundColor = .groupTableViewBackground
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

    private func updateModel(for weekOffset: Int) {
        refreshControl.beginRefreshing()
        animateTableUpdate(animation: .hide)
        viewModel.update(for: UserDefaults.standard.integer(forKey: "UserId"), on: weekOffset)
    }

    private func updateWeekDates(on weekOffset: Int) {
        navigationItem.prompt = "\(TimeManager.shared.getWeekBoundaries(for: weekOffset))"
    }

    private func animateTableUpdate(animation: TableUpdateAnimationType) {
        switch animation {
        case .hide: table.isHidden = true
        case .show: UIView.transition(
            with: table,
            duration: 0.5,
            options: [.allowAnimatedContent, .showHideTransitionViews, .transitionCrossDissolve/*, .curveEaseOut*/],
            animations: { [unowned self] in self.table.isHidden = false })
        }
    }


}
