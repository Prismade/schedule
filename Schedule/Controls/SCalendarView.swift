import UIKit

final class SNibCalendarView: UIStackView {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    static func loadFromNib() -> SNibCalendarView {
        let bundle = Bundle(for: self)
        let nib = UINib(nibName: "SCalendarView", bundle: bundle)
        let allViewsFromNib = nib.instantiate(withOwner: nil, options: nil)
        let calendarView = allViewsFromNib.first! as! SNibCalendarView
        return calendarView
    }
    
}

enum SScrollDirection {
    case left
    case none
    case right
}

@IBDesignable
final class SCalendarView: UIView {
    
    struct IndexPath {
        let weekOffset: Int
        let day: SWeekDay
    }
    
    // MARK: - Public Properties
    
    // delegate & datasource closures
    var weekDaysForPage: ((Int) -> [Date])?
    var weekWasChanged: ((SCalendarView, Int) -> Void)?
    var dayWasSelected: ((SCalendarView, IndexPath) -> Void)?
    
    var view: SNibCalendarView
    var weekOffset: Int = 0 {
        didSet {
            updateWeekDates()
            view.scrollView.setContentOffset(
                CGPoint(
                    x: pageSize.width,
                    y: view.scrollView.contentOffset.y),
                animated: false)
            previousPhysicalPage = currentPhysicalPage
        }
    }
    var selectedDay: SWeekDay = .monday {
        didSet {
            for week in view.scrollView.subviews {
                (week as! SWeekView).selectedDay = selectedDay
            }
        }
    }
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
    private var pageSize: CGSize {
        return view.scrollView.frame.size
    }
    private var previousPhysicalPage = 0
    private var currentPhysicalPage: Int {
        let pageWidth = pageSize.width
        let currentOffset = view.scrollView.contentOffset.x
        return Int(currentOffset / pageWidth)
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        view = SNibCalendarView.loadFromNib()
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        view = SNibCalendarView.loadFromNib()
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
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 8.0)
        ])
        
        view.scrollView.scrollsToTop = false
        view.scrollView.delegate = self
        
        for w in view.scrollView.subviews {
            (w as! SWeekView).dayWasSelected = { day in
                self.selectedDay = day
                self.dayWasSelected?(
                    self,
                    IndexPath(weekOffset: self.weekOffset, day: self.selectedDay))
            }
        }
    }
    
    // Call this after parent viewcontroller's did layout subviews
    func instantiateView(for selectedDay: SWeekDay = .monday) {
        guard !didInstantiate else { return }
        
        view.layoutIfNeeded()
        view.scrollView.setContentOffset(
            CGPoint(
                x: pageSize.width,
                y: view.scrollView.contentOffset.y),
            animated: false)
        weekOffset = 0
        self.selectedDay = selectedDay
        previousPhysicalPage = currentPhysicalPage
        didInstantiate = true
    }
    
    // MARK: - Private Methods
    
    private func updateWeekDates() {
        guard let daysGetter = weekDaysForPage else { return }
        
        let prevWeek = view.scrollView.subviews.first(where: { $0.tag == 1 }) as! SWeekView
        prevWeek.days = daysGetter(weekOffset - 1)
        let currWeek = view.scrollView.subviews.first(where: { $0.tag == 2 }) as! SWeekView
        currWeek.days = daysGetter(weekOffset)
        let nextWeek = view.scrollView.subviews.first(where: { $0.tag == 3 }) as! SWeekView
        nextWeek.days = daysGetter(weekOffset + 1)
    }
    
}

// MARK: - UISCrollViewDelegate

extension SCalendarView: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard lastScrollDirection != .none else { return }
        if lastScrollDirection == .left {
            weekOffset -= 1
        } else if lastScrollDirection == .right {
            weekOffset += 1
        }
        weekWasChanged?(self, weekOffset)
    }
    
}
