//
//  Groups.swift
//  schedule
//
//  Created by Егор Молчанов on 07/08/2019.
//  Copyright © 2019 Prismade. All rights reserved.
//

struct Group: Decodable {

    let title: String
    let id: Int
    let code: String
    let level: String

    enum CodingKeys: String, CodingKey {
        case title
        case id = "idgruop"
        case code = "Codedirection"
        case level = "levelEducation"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        title = try container.decode(String.self, forKey: .title)
        id = try container.decode(Int.self, forKey: .id)
        code = try container.decode(String.self, forKey: .code)
        level = try container.decode(String.self, forKey: .level)
    }
}
