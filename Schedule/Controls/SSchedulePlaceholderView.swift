import UIKit

final class SNibSchedulePlaceholderView: UIView {
    
    @IBOutlet weak var message: UILabel!
    
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

    }
    
}
