import UIKit

enum CellType {
    case student
    case teacher
}


final class ScheduleTableViewCell: UITableViewCell {

    @IBOutlet weak var userAndLessonType: UIStackView!
    @IBOutlet weak var lessonTimeBounds: UIView!
    @IBOutlet weak var line: UIView!
    @IBOutlet weak var beginTime: UILabel!
    @IBOutlet weak var endTime: UILabel!
    @IBOutlet weak var lessonTitle: UILabel!
    @IBOutlet weak var lessonType: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var subgroup: UILabel!

    public func configure(with lesson: Lesson?, cellType: CellType) {
        if cellType == .student || cellType == .teacher {
            if let lesson = lesson {
                let bounds = TimeManager.shared.getTimeBoundaries(for: lesson.number).split(separator: "-")
                lessonTimeBounds.isHidden = false
                line.isHidden = false
                beginTime.text = String(bounds[0])
                endTime.text = String(bounds[1])
                lessonTitle.text = lesson.subject
                if lesson.subgroup != 0 {
                    subgroup.isHidden = false
                    subgroup.text = "\(NSLocalizedString("subgroup", comment: "")) \(lesson.subgroup)"
                } else {
                    subgroup.isHidden = true
                }
                userAndLessonType.isHidden = false
                if cellType == .student {
                    userName.text = lesson.employeeNameDesigned
                } else if cellType == .teacher {
                    userName.text = lesson.groupTitleDesigned
                }
                lessonType.text = "(\(lesson.type))"
                location.isHidden = false
                location.text = lesson.locationDesigned
            } else {
                lessonTimeBounds.isHidden = true
                line.isHidden = true
                lessonTitle.text = "\(NSLocalizedString("noClasses", comment: ""))"
                userAndLessonType.isHidden = true
                location.isHidden = true
                subgroup.isHidden = true
            }
        }
    }
    
    public func configure(with exam: Exam) {
        lessonTitle.text = exam.subject
        beginTime.text = exam.dateTime
        endTime.isHidden = true
        lessonType.text = exam.type
        if UserDefaults.standard.bool(forKey: "Teacher") {
            userName.text = exam.groupDesigned
        } else {
            userName.text = exam.employeeNameDesigned
        }
        
        location.text = exam.locationDesigned
        subgroup.isHidden = true
    }


}
