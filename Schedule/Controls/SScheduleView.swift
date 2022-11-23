import UIKit

final class SNibScheduleView: UIScrollView {
    
    @IBOutlet var tableViews: [UITableView]!
    
    static func loadFromNib() -> SNibScheduleView {
        let bundle = Bundle(for: self)
        let nib = UINib(nibName: "SScheduleView", bundle: bundle)
        let allViewsFromNib = nib.instantiate(withOwner: nil, options: nil)
        let scheduleView = allViewsFromNib.first! as! SNibScheduleView
        return scheduleView
    }
    
}

@IBDesignable
final class SScheduleView: UIView {
    
    struct IndexPath {
        let week: Int
        let day: Int
        let classNumber: Int
    }
    
    enum WeekChangeDirection {
        case back
        case forward
    }
    
    // MARK: - Public Properties
    
    //delegate closures
    var dayWasChanged: ((SScheduleView, SWeekDay) -> Void)?
    var weekWasChanged: ((SScheduleView, WeekChangeDirection) -> Void)?
    
    let reuseIdentifier = "ScheduleCell"
    var view: SNibScheduleView
    weak var tableViewDelegate: UITableViewDelegate? {
        didSet {
            for t in view.tableViews {
                t.delegate = tableViewDelegate
            }
        }
    }
    weak var tableViewDataSource: UITableViewDataSource? {
           didSet {
               for t in view.tableViews {
                   t.dataSource = tableViewDataSource
               }
           }
       }
    var shownDay: SWeekDay = .monday
    var lastScrollDirection: SScrollDirection {
        if currentPhysicalPage == previousPhysicalPage {
            return .none
        } else if currentPhysicalPage > previousPhysicalPage {
            return .right
        } else {
            return .left
        }
    }
    
    // MARK: - Private Properties
    
    private var didInstantiate = false
    private var previousPhysicalPage = 1
    private var currentPhysicalPage: Int {
        let pageWidth = pageSize.width
        let currentOffset = view.contentOffset.x
        return Int(currentOffset / pageWidth)
    }
    private var pageSize: CGSize {
        return view.frame.size
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        view = SNibScheduleView.loadFromNib()
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        view = SNibScheduleView.loadFromNib()
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topAnchor.constraint(equalTo: view.topAnchor),
            trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        view.scrollsToTop = false
        view.delegate = self
        
        for table in view.subviews {
            let t = table as! UITableView
            t.register(UINib(nibName: "SScheduleTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
            t.refreshControl = UIRefreshControl()
            t.refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        }
      
      ((view.subviews.first { $0.tag == 0 }) as? UITableView)?.refreshControl?.beginRefreshing()
      ((view.subviews.first { $0.tag == 7 }) as? UITableView)?.refreshControl?.beginRefreshing()
    }
    
    // Call this after parent viewcontroller's did layout subviews
    func instantiateView(for day: SWeekDay = .monday) {
        guard !didInstantiate else { return }
        
        view.layoutIfNeeded()
        shownDay = day
        view.setContentOffset(CGPoint(
            x: pageSize.width * CGFloat(day.rawValue),
            y: view.contentOffset.y), animated: false)
        
        didInstantiate = true
    }
    
    // MARK: - Public Methods
    
    func scrollToDay(_ day: SWeekDay) {
        view.setContentOffset(CGPoint(
            x: pageSize.width * CGFloat(day.rawValue),
            y: view.contentOffset.y), animated: true)
        previousPhysicalPage = currentPhysicalPage
        shownDay = day
    }
    
    func prepareForUpdate() {
        for table in view.tableViews {
            guard table.tag != 0 && table.tag != 7 else { continue }
            table.reloadData()
            table.refreshControl?.beginRefreshing()
        }
    }
    
    func reloadData() {
        for table in view.tableViews {
            guard table.tag != 0 && table.tag != 7 else { continue }
            table.refreshControl?.endRefreshing()
            table.reloadData()
        }
    }
    
    // MARK: - Private Methods
    
    private func recenterIfNecessary() {
        if currentPhysicalPage == 0 {
            weekWasChanged?(self, .back)
            shownDay = .saturday
            view.setContentOffset(CGPoint(
                x: pageSize.width * CGFloat(shownDay.rawValue),
                y: view.contentOffset.y), animated: false)
        } else if currentPhysicalPage == 7 {
            weekWasChanged?(self, .forward)
            shownDay = .monday
            view.setContentOffset(CGPoint(
                x: pageSize.width * CGFloat(shownDay.rawValue),
                y: view.contentOffset.y), animated: false)
        } else {
            shownDay = SWeekDay(rawValue: currentPhysicalPage)!
        }
        
        dayWasChanged?(self, shownDay)
        previousPhysicalPage = currentPhysicalPage
    }
  
    @objc
    func refresh(_ sender: UIRefreshControl) {
        sender.endRefreshing()
    }
}

// MARK: - UISCrollViewDelegate

extension SScheduleView: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard lastScrollDirection != .none else { return }
        recenterIfNecessary()
    }
    
}
