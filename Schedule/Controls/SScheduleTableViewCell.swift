import UIKit
import CommonCrypto

final class SScheduleTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var userAndClassKind: UIStackView!
    @IBOutlet weak var beginTime: UILabel!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var classTitle: UILabel!
    @IBOutlet weak var classKind: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var subgroup: UILabel!
    @IBOutlet weak var line: UIView!
    
    // MARK: - Public Methods
    
    func configure(with classData: SClass) {
        if let color = UIColor(for: classData.subject) {
            line.backgroundColor = color
        }
        
        let bounds = STimeManager.shared.timetable[classData.number]!
        beginTime.text = bounds.0
        endTime.text = bounds.1
        classTitle.text = classData.subject
        if classData.subgroup != 0 {
            subgroup.isHidden = false
            subgroup.text = "\(NSLocalizedString("Subgroup", comment: "")) \(classData.subgroup)"
        } else {
            subgroup.isHidden = true
        }
        userAndClassKind.isHidden = false
        userName.text = classData.employeeNameDesigned
        classKind.text = "(\(classData.kind))"
        location.isHidden = false
        location.text = classData.locationDesigned
    }
    
    func configure(with exam: SExam) {
      if let color = UIColor(for: exam.subject) {
            line.backgroundColor = color
        }
        
        classTitle.text = exam.subject
        beginTime.text = exam.time
        endTime.text = exam.date
        classKind.text = exam.kind
        userName.text = exam.employeeNameDesigned

        location.text = exam.locationDesigned
        subgroup.isHidden = true
    }
}
