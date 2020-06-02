import UIKit
import CommonCrypto

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
    @IBOutlet weak var line: UIView!
    
    // MARK: - Public Methods
    
    func configure(with classData: SClass, cellKind: SCellKind) {
        if let color = generateColor(for: classData.subject) {
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
    
    func generateColor(for className: String) -> UIColor? {
        let digest = MD5(className)
        
        let len = digest.count
        if len >= 3 {
            let r = CGFloat(digest[len - 1]) / 256.0
            let g = CGFloat(digest[len - 2]) / 256.0
            let b = CGFloat(digest[len - 3]) / 256.0
            
            let color = UIColor(red: r, green: g, blue: b, alpha: 1.0)
            
            return color
        } else {
            return nil
        }
    }
    
}

func MD5(_ str: String) -> [UInt8] {
    if let strData = str.data(using: String.Encoding.utf8) {
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
 
        _ = strData.withUnsafeBytes {
            CC_MD5($0.baseAddress, UInt32(strData.count), &digest)
        }

        return digest
    }
    return [UInt8]()
}
