import UIKit

enum CellType {
    case student
    case teacher
}


final class ScheduleTableViewCell: UITableViewCell {

    @IBOutlet weak var lessonNumber: UILabel!
    @IBOutlet weak var lessonTitle: UILabel!
    @IBOutlet weak var lessonTime: UILabel!
    @IBOutlet weak var special: UILabel!
    @IBOutlet weak var lessonType: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var subgroup: UILabel!

    public func configure(with lesson: Lesson?, cellType: CellType) {
        if cellType == .student || cellType == .teacher {
            if let lesson = lesson {
                lessonNumber.text = String(lesson.number)
                lessonTitle.text = lesson.subject
                lessonTime.text = TimeManager.shared.getTimeBoundaries(for: lesson.number)
                if lesson.special != "" {
                    special.text = "(\(lesson.special))"
                } else {
                    special.text = ""
                }
                
                lessonType.text = "(\(lesson.type))"
                if cellType == .student {
                    userName.text = lesson.employeeNameDesigned
                } else if cellType == .teacher {
                    userName.text = lesson.groupTitleDesigned
                }
                location.text = lesson.locationDesigned
                if lesson.subgroup != 0 {
                    subgroup.text = "Подгруппа \(lesson.subgroup)"
                } else {
                    subgroup.text = ""
                }
            } else {
                lessonNumber.text = ""
                lessonTitle.text = "Нет пар"
                lessonTime.text = ""
                special.text = ""
                lessonType.text = ""
                userName.text = ""
                location.text = ""
                subgroup.text = ""
            }
        }
    }
    
    public func configure(with exam: Exam) {
        lessonNumber.text = ""
        lessonNumber.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        lessonTitle.text = exam.subject
        lessonTime.text = exam.dateTime
        special.text = ""
        lessonType.text = exam.type
        if UserDefaults.standard.bool(forKey: "Teacher") {
            userName.text = exam.groupDesigned
        } else {
            userName.text = exam.employeeNameDesigned
        }
        
        location.text = exam.locationDesigned
        subgroup.text = ""
    }


}
