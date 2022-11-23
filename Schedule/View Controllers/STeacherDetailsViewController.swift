import UIKit

class STeacherDetailsViewController: UIViewController {
  
  // MARK: - IBOutlets
  
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var scrollView: UIScrollView!
  @IBOutlet weak var stackView: UIStackView!
  @IBOutlet weak var profilePicture: UIImageView!
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var position: UILabel!
  @IBOutlet weak var degree: UILabel!
  @IBOutlet weak var rank: UILabel!
  @IBOutlet weak var address: UILabel!
  @IBOutlet weak var phone: SCopyableLabel!
  @IBOutlet weak var email: UILabel!
  
  // MARK: - IBActions
  
  @IBAction func closeButtonTap(_ sender: Any) {
    navigationController?.dismiss(animated: true)
  }
  
  // MARK: - Public Properties
  
  var employeeId: Int?
  
  // MARK: - Private Properties
  
  private var employee: SEmployee?
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    scrollView.isHidden = true
    activityIndicator.isHidden = false
    activityIndicator.startAnimating()
    
    profilePicture.layer.cornerRadius = profilePicture.frame.size.width / 2;
    profilePicture.clipsToBounds = true
    
    if let id = employeeId {
      SEmployeeManager.shared.requestData(for: id) { result in
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
  
  // MARK: - Private Methods
  
  private func insertData() {
    let placeholder = UIImage(named: "DefaultProfilePicture")
    profilePicture.image = placeholder
    
    Task { [weak self] in
      guard let self, let imagePath = employee?.image else { return }
      do {
        let data = try await NetworkWorker().data(from: Oreluniver.other(path: imagePath))
        guard let image = UIImage(data: data) else { return }
        await MainActor.run {
          UIView.animate(withDuration: 0.5) {
            self.profilePicture.image = image
          }
        }
      } catch {
        print(error.localizedDescription)
      }
    }
    
    name.text = employee!.name
    
    let boldFontAttribute = [NSAttributedString.Key.font:
                              UIFont.systemFont(ofSize: 17, weight: .semibold)]
    let fontAttribute = [NSAttributedString.Key.font:
                          UIFont.systemFont(ofSize: 17, weight: .light)]
    
    let positionText = NSMutableAttributedString(
      string: "\(NSLocalizedString("Position", comment: ""))",
      attributes: boldFontAttribute)
    positionText.append(NSAttributedString(string: employee!.allPositions, attributes: fontAttribute))
    position.attributedText = positionText
    
    if let degree = employee!.degree {
      let degreeText = NSMutableAttributedString(
        string: "\(NSLocalizedString("Degree", comment: ""))",
        attributes: boldFontAttribute)
      degreeText.append(NSAttributedString(string: degree, attributes: fontAttribute))
      self.degree.attributedText = degreeText
    } else {
      self.degree.isHidden = true
    }
    
    if let rank = employee!.rank {
      let rankText = NSMutableAttributedString(
        string: "\(NSLocalizedString("Rank", comment: ""))",
        attributes: boldFontAttribute)
      rankText.append(NSAttributedString(string: rank, attributes: fontAttribute))
      self.rank.attributedText = rankText
    } else {
      self.rank.isHidden = true
    }
    
    guard
      employee!.contacts.address != nil ||
      employee!.contacts.email != nil ||
      employee!.contacts.phone != nil
    else {
      self.address.text = "\(NSLocalizedString("NoContacts", comment: ""))"
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
  
}
