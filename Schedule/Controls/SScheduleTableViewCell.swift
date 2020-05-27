import UIKit

enum SCellKind {
    case student
    case teacher
}

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
    
    // MARK: - Public Methods
    
    func configure(with classData: SClass, cellKind: SCellKind) {
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
        if cellKind == .student {
            userName.text = classData.employeeNameDesigned
        } else if cellKind == .teacher {
            userName.text = classData.groupTitleDesigned
        }
        classKind.text = "(\(classData.kind))"
        location.isHidden = false
        location.text = classData.locationDesigned
    }
    
    func configure(with exam: SExam, cellKind: SCellKind) {
        
        classTitle.text = exam.subject
        beginTime.text = exam.time
        endTime.text = exam.date
        classKind.text = exam.kind
        if cellKind == .teacher {
            userName.text = exam.groupDesigned
        } else {
            userName.text = exam.employeeNameDesigned
        }

        location.text = exam.locationDesigned
        subgroup.isHidden = true
    }
    
}
