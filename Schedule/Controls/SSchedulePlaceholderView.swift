import UIKit
import AFCurvedArrowView

final class SNibSchedulePlaceholderView: UIView {
    
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var arrow: AFCurvedArrowView!
    
    static func loadFromNib() -> SNibSchedulePlaceholderView {
        let bundle = Bundle(for: self)
        let nib = UINib(nibName: "SSchedulePlaceholderView", bundle: bundle)
        let allViewsFromNib = nib.instantiate(withOwner: nil, options: nil)
        let schedulePlaceholder = allViewsFromNib.first! as! SNibSchedulePlaceholderView
        return schedulePlaceholder
    }
    
}

@IBDesignable
final class SSchedulePlaceholderView: UIView {
    
    // MARK: - Public Properties
    
    var view: SNibSchedulePlaceholderView
    var didInstantiate: Bool = false
    var message: String = "Message" {
        didSet {
            view.message.text = message
        }
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        view = SNibSchedulePlaceholderView.loadFromNib()
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        view = SNibSchedulePlaceholderView.loadFromNib()
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
        
        view.arrow.lineColor = UIColor(named: "DayOffTitleText")
        view.arrow.lineWidth = 2.0
        
        guard let arrow = view.arrow else { return }
        
        arrow.arrowHeadHeight = 20.0
        arrow.arrowHeadWidth = 10.0

        arrow.arrowTail = CGPoint(x: 0.5, y: 1.0)
        arrow.arrowHead = CGPoint(x: 0.95, y: 0.0)
        arrow.controlPoint1 = CGPoint(x: 0.5, y: 0.5)
        arrow.controlPoint2 = CGPoint(x: 1.0, y: 0.5)
        arrow.curveType = .cubic

    }
    
}
