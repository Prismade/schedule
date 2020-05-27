import UIKit

final class SNibDayView: UIView {
    
    @IBOutlet weak var dayLabel: UILabel!
    
    static func loadFromNib() -> SNibDayView {
        let bundle = Bundle(for: self)
        let nib = UINib(nibName: "SDayView", bundle: bundle)
        let allViewsFromNib = nib.instantiate(withOwner: nil, options: nil)
        let dayView = allViewsFromNib.first! as! SNibDayView
        dayView.dayLabel.layer.cornerRadius = 20.0
        dayView.dayLabel.layer.masksToBounds = true
        return dayView
    }
    
}

@IBDesignable
final class SDayView: UIView {
    
    // MARK: - Public Properties
    
    var view: SNibDayView
    
    @IBInspectable var dayOff: Bool = false {
        didSet {
            if selected {
                view.dayLabel.textColor = UIColor(named: "DaySelectedText")
            } else {
                if dayOff {
                    view.dayLabel.textColor = UIColor(named: "DayOffText")
                } else {
                    view.dayLabel.textColor = UIColor(named: "WorkingDayText")
                }
            }
        }
    }
    @IBInspectable var selected: Bool = false {
        didSet {
            if selected {
                view.dayLabel.backgroundColor = UIColor(named: "DaySelectedBackground")
                view.dayLabel.textColor = UIColor(named: "DaySelectedText")
            } else {
                view.dayLabel.backgroundColor = UIColor(named: "DayBackground")
                if dayOff {
                    view.dayLabel.textColor = UIColor(named: "DayOffText")
                } else {
                    view.dayLabel.textColor = UIColor(named: "WorkingDayText")
                }
            }
        }
    }
    @IBInspectable var cornerRadius: Float = 20.0 {
        didSet {
            view.dayLabel.layer.cornerRadius = CGFloat(cornerRadius)
        }
    }
    @IBInspectable var text: String = "0" {
        didSet {
            view.dayLabel.text = text
        }
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        view = SNibDayView.loadFromNib()
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        view = SNibDayView.loadFromNib()
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
    }
    
}
