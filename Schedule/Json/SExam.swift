import Foundation

class SExam: Decodable {
    let fullDate: String
    let date: String
    let group: String
    let subject: String
    let kind: String
    let room: String
    let time: String
    let weekDay: Int
    let patronymic: String
    let firstName: String
    let lastName: String
    let employeeId: Int
    
    var employeeNameDesigned: String {
        guard firstName != "", lastName != "", patronymic != "" else { return "" }
        return "\(lastName) \(firstName.first!).\(patronymic.first!)."
    }
    var groupDesigned: String {
        return "\(group)"
    }
    var locationDesigned: String {
        return "\(room)"
    }
    
    enum CodingKeys: String, CodingKey {
        case fullDate = "DBDate"
        case date = "DateLesson"
        case group = "Title"
        case subject = "TitleSubject"
        case kind = "TypeLesson"
        case room = "NumberRoom"
        case time = "Time"
        case weekDay = "DayWeek"
        case patronymic = "SecondName"
        case firstName = "Name"
        case lastname = "Family"
        case employeeId = "employee_id"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        fullDate = try container.decode(String.self, forKey: .fullDate)
        date = try container.decode(String.self, forKey: .date)
        group = try container.decode(String.self, forKey: .group)
        subject = try container.decode(String.self, forKey: .subject)
        kind = try container.decode(String.self, forKey: .kind)
        room = try container.decode(String.self, forKey: .room)
        time = try container.decode(String.self, forKey: .time)
        weekDay = try container.decode(Int.self, forKey: .weekDay)
        patronymic = try container.decode(String.self, forKey: .patronymic)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastname)
        employeeId = try container.decode(Int.self, forKey: .employeeId)
    }
    
}
