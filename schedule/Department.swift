import Foundation


class Department: NSObject, Decodable {
    let id: Int
    @objc let title: String
    @objc let short: String
    
    enum CodingKeys: String, CodingKey {
        case id = "idDivision"
        case title = "titleDivision"
        case short = "shortTitle"
    }
    
    enum ExpressionKeys: String {
        case title
        case short
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        short = try container.decode(String.self, forKey: .short)
    }
}
