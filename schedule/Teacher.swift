import Foundation


class Teacher: NSObject, Decodable {
    let id: Int
    @objc let lastName: String
    @objc let firstName: String
    @objc let patronymic: String
    let fullName: String
    var name: String {
        guard firstName != "", lastName != "", patronymic != "" else { return "" }
        return "\(lastName) \(firstName.first!).\(patronymic.first!)."
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "employee_id"
        case lastName = "Family"
        case firstName = "Name"
        case patronymic = "SecondName"
        case fullName = "fio"
    }
    
    enum ExpressionKeys: String {
        case lastName
        case firstName
        case patronymic
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        lastName = try container.decode(String.self, forKey: .lastName)
        firstName = try container.decode(String.self, forKey: .firstName)
        patronymic = try container.decode(String.self, forKey: .patronymic)
        fullName = try container.decode(String.self, forKey: .fullName)
    }
}
