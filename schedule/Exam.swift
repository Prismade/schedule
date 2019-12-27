import Foundation


class Exam: Decodable {
    let fullDate: String
    let date: String
    let title: String
    let subject: String
    let type: String
    let room: String
    let time: String
    let weekDay: Int
    let patronymic: String
    let firstName: String
    let lastName: String
    let employeeId: Int
    
    var employeeName: String {
        guard firstName != "", lastName != "", patronymic != "" else { return "" }
        return "👤 \(lastName) \(firstName.first!).\(patronymic.first!)."
    }
    var fullEmployeeName: String {
        guard firstName != "", lastName != "", patronymic != "" else { return "" }
        return "👤 \(lastName) \(firstName) \(patronymic)"
    }
    var location: String {
        return "📍 \(room)"
    }
    
    enum CodingKeys: String, CodingKey {
        case fullDate = "DBDate"
        case date = "DateLesson"
        case title = "Title"
        case subject = "TitleSubject"
        case type = "TypeLesson"
        case room = "NumberRoom"
        case time = "Time"
        case weekDay = "DayWeek"
        case patronymic = "Family"
        case firstName = "Name"
        case lastname = "SecondName"
        case employeeId = "employee_id"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        fullDate = try container.decode(String.self, forKey: .fullDate)
        date = try container.decode(String.self, forKey: .date)
        title = try container.decode(String.self, forKey: .title)
        subject = try container.decode(String.self, forKey: .subject)
        type = try container.decode(String.self, forKey: .type)
        room = try container.decode(String.self, forKey: .room)
        time = try container.decode(String.self, forKey: .time)
        weekDay = try container.decode(Int.self, forKey: .weekDay)
        patronymic = try container.decode(String.self, forKey: .patronymic)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastname)
        employeeId = try container.decode(Int.self, forKey: .employeeId)
    }
}
