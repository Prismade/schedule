import Foundation


class Teacher: Decodable {
    let id: Int
    let lastName: String
    let firstName: String
    let patronymic: String
    let fullName: String
    
    enum CodingKeys: String, CodingKey {
        case id = "employee_id"
        case lastName = "Family"
        case firstName = "Name"
        case patronymic = "SecondName"
        case fullName = "fio"
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
