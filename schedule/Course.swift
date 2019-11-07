import Foundation


class Course: Decodable {
    let course: Int

    enum CodingKeys: String, CodingKey {
        case course = "kurs"
    }

    init(decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        course = try container.decode(Int.self, forKey: .course)
    }
}
