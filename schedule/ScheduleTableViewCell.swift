import UIKit


final class ScheduleTableViewCell: UITableViewCell {

    @IBOutlet weak var lessonNumber: UILabel!
    @IBOutlet weak var lessonTitle: UILabel!
    @IBOutlet weak var lessonTime: UILabel!
    @IBOutlet weak var special: UILabel!
    @IBOutlet weak var lessonType: UILabel!
    @IBOutlet weak var teacherName: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var subgroup: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    public func configure(with lesson: Lesson?) {
        if let lesson = lesson {
            lessonNumber.text = String(lesson.number)
            lessonTitle.text = lesson.subject
            lessonTime.isHidden = false
            lessonTime.text = TimeManager.shared.getTimeBoundaries(for: lesson.number)
            if lesson.special != "" {
                special.isHidden = false
                special.text = lesson.special
            } else {
                special.isHidden = true
            }
            lessonType.isHidden = false
            lessonType.text = "(\(lesson.type))"
            teacherName.isHidden = false
            teacherName.text = lesson.employeeName
            location.isHidden = false
            location.text = lesson.location
            if lesson.subgroup != 0 {
                subgroup.isHidden = false
                subgroup.text = "Подгруппа \(lesson.subgroup)"
            } else {
                subgroup.isHidden = true
            }
        } else {
            lessonNumber.text = ""
            lessonTitle.text = "Нет пар"
            lessonTime.isHidden = true
            special.isHidden = true
            lessonType.isHidden = true
            teacherName.isHidden = true
            location.isHidden = true
            subgroup.isHidden = true
        }
    }

    public func update(with lesson: Lesson?) {
        
    }

}
