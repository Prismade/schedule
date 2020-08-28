import UIKit

final class SNibWeekView: UIStackView {
    
    @IBOutlet var days: [SDayView]!
    
    @IBOutlet var tapRecognizers: [UITapGestureRecognizer]!
    
    static func loadFromNib() -> SNibWeekView {
        let bundle = Bundle(for: self)
        let nib = UINib(nibName: "SWeekView", bundle: bundle)
        let allViewsFromNib = nib.instantiate(withOwner: nil, options: nil)
        let weekView = allViewsFromNib.first! as! SNibWeekView
        return weekView
    }
    
}

@IBDesignable
final class SWeekView: UIView {
    
    // MARK: - Public Properties
    
    var dayWasSelected: ((SWeekDay) -> Void)?
    
    var view: SNibWeekView
    var selectedDay: SWeekDay = .monday {
        didSet {
            view.days.first(where: { $0.tag == oldValue.rawValue })?.selected = false
            view.days.first(where: { $0.tag == selectedDay.rawValue })?.selected = true
        }
    }
    var days = [Date]() {
        didSet {
            for i in 0..<days.count {
                let dateFormatter = DateFormatter()
                dateFormatter.setLocalizedDateFormatFromTemplate("d")
                let texts = days.map {
                    dateFormatter.string(from: $0)
                }
                view.days.first(where: { $0.tag == i + 1 })?.text = texts[i]
            }
        }
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        view = SNibWeekView.loadFromNib()
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        view = SNibWeekView.loadFromNib()
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
        
        for recognizer in view.tapRecognizers {
            recognizer.addTarget(self, action: #selector(handleTap(_:)))
        }
    }
    
    // MARK: - Private Methods
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            selectedDay = SWeekDay(rawValue: sender.view!.tag)!
            dayWasSelected?(selectedDay)
        }
    }
    
}
