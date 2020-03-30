import Foundation


class Lesson: Codable, Comparable {
    let groupId: Int
    let subgroup: Int
    let subject: String
    let type: String
    let number: Int
    let weekDay: Int
    let building: String
    let room: String
    let special: String
    let groupTitle: String
    let employeeId: Int?
    let patronymic: String
    let firstName: String
    let lastName: String
    var employeeNameDesigned: String {
        guard firstName != "", lastName != "", patronymic != "" else { return "" }
        return "\(lastName) \(firstName.first!).\(patronymic.first!)."
    }
    var fullEmployeeNameDesigned: String {
        guard firstName != "", lastName != "", patronymic != "" else { return "" }
        return "\(lastName) \(firstName) \(patronymic)"
    }
    var groupTitleDesigned: String {
        return "\(groupTitle)"
    }
    var locationDesigned: String {
        return "\(building) корпус, ауд. \(room)"
    }
    var location: String {
        return "\(building)-\(room)"
    }

    enum CodingKeys: String, CodingKey {
        case groupId = "idGruop"
        case subgroup = "NumberSubGruop"
        case subject = "TitleSubject"
        case type = "TypeLesson"
        case number = "NumberLesson"
        case weekDay = "DayWeek"
        case building = "Korpus"
        case room = "NumberRoom"
        case special
        case groupTitle = "title"
        case employeeId = "employee_id"
        case patronymic = "SecondName"
        case firstName = "Name"
        case lastName = "Family"
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        groupId = try container.decode(Int.self, forKey: .groupId)
        subgroup = try container.decode(Int.self, forKey: .subgroup)
        subject = try container.decode(String.self, forKey: .subject)
        type = try container.decode(String.self, forKey: .type)
        number = try container.decode(Int.self, forKey: .number)
        weekDay = try container.decode(Int.self, forKey: .weekDay)
        building = try container.decode(String.self, forKey: .building)
        room = try container.decode(String.self, forKey: .room)
        special = try container.decode(String.self, forKey: .special)
        groupTitle = try container.decode(String.self, forKey: .groupTitle)
        employeeId = try? container.decode(Int.self, forKey: .employeeId)
        patronymic = try container.decode(String.self, forKey: .patronymic)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(groupId, forKey: .groupId)
        try container.encode(subgroup, forKey: .subgroup)
        try container.encode(subject, forKey: .subject)
        try container.encode(type, forKey: .type)
        try container.encode(number, forKey: .number)
        try container.encode(weekDay, forKey: .weekDay)
        try container.encode(building, forKey: .building)
        try container.encode(room, forKey: .room)
        try container.encode(special, forKey: .special)
        try container.encode(groupTitle, forKey: .groupTitle)
        if let employeeId = employeeId {
            try container.encode(employeeId, forKey: .employeeId)
        }
        try container.encode(patronymic, forKey: .patronymic)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
    }

    static func < (lhs: Lesson, rhs: Lesson) -> Bool {
        if lhs.weekDay != rhs.weekDay {
            return lhs.weekDay < rhs.weekDay
        } else {
            return lhs.number < rhs.number
        }
    }

    static func == (lhs: Lesson, rhs: Lesson) -> Bool {
        if lhs.weekDay == rhs.weekDay {
            return lhs.number == rhs.number
        }

        return false
    }
}
