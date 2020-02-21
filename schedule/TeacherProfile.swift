import UIKit
import Kingfisher


class TeacherProfileViewController: UIViewController {
    
    var employeeId: Int? = nil
    private var employee: Employee? = nil
    private let baseUrl = "http://oreluniver.ru"

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var position: UILabel!
    @IBOutlet weak var degree: UILabel!
    @IBOutlet weak var rank: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var phone: CopyableLabel!
    @IBOutlet weak var email: UILabel!
    @IBAction func onCloseButtonTap(_ sender: UIBarButtonItem) {
        navigationController?.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2;
        profileImage.clipsToBounds = true
        profileImage.kf.indicatorType = .activity
        
        if let id = employeeId {
            EmployeeManager.shared.data(for: id) { result in
                switch result {
                case .success(let data):
                    self.employee = data
                    self.insertData()
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.scrollView.isHidden = false
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func insertData() {
        if let imageUrl = employee!.image {
            let url = URL(string: "\(baseUrl)\(imageUrl)")!
            profileImage.kf.setImage(with: url, options: [.transition(.fade(0.5))])
        } else {
            let placeholder = UIImage(named: "ProfileImagePlaceholder")
            profileImage.image = placeholder
        }
        
        name.text = employee!.name
        
        let boldFontAttribute = [NSAttributedString.Key.font:
            UIFont.systemFont(ofSize: 17, weight: .semibold)]
        let fontAttribute = [NSAttributedString.Key.font:
            UIFont.systemFont(ofSize: 17, weight: .light)]
        
        let positionText = NSMutableAttributedString(
            string: "\(NSLocalizedString("position", comment: ""))",
            attributes: boldFontAttribute)
        positionText.append(NSAttributedString(string: employee!.allPositions, attributes: fontAttribute))
        position.attributedText = positionText
        
        if let degree = employee!.degree {
            let degreeText = NSMutableAttributedString(
                string: "\(NSLocalizedString("degree", comment: ""))",
                attributes: boldFontAttribute)
            degreeText.append(NSAttributedString(string: degree, attributes: fontAttribute))
            self.degree.attributedText = degreeText
        } else {
            self.degree.isHidden = true
        }
        
        if let rank = employee!.rank {
            let rankText = NSMutableAttributedString(
                string: "\(NSLocalizedString("rank", comment: ""))",
                attributes: boldFontAttribute)
            rankText.append(NSAttributedString(string: rank, attributes: fontAttribute))
            self.rank.attributedText = rankText
        } else {
            self.rank.isHidden = true
        }
        
        guard employee!.contacts.address != nil ||
            employee!.contacts.email != nil ||
            employee!.contacts.phone != nil
        else {
            self.address.text = "\(NSLocalizedString("noContacts", comment: ""))"
            self.phone.isHidden = true
            self.email.isHidden = true
            stackView.layoutIfNeeded()
            return
        }
        
        if let address = employee!.contacts.address {
            self.address.text = address
        } else {
            self.address.isHidden = true
        }
        
        if let phone = employee!.contacts.phone {
            self.phone.text = phone
        } else {
            self.phone.isHidden = true
        }
        
        if let email = employee!.contacts.email {
            self.email.text = email
        } else {
            self.email.isHidden = true
        }
        
        stackView.layoutIfNeeded()
    }
    
    private func phoneLabelTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        if gestureRecognizer.state == .recognized {
            UIPasteboard.general.string = phone.text!
        }
    }


}
