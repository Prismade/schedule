//
//  Division.swift
//  schedule
//
//  Created by Егор Молчанов on 07/08/2019.
//  Copyright © 2019 Prismade. All rights reserved.
//

import Foundation

struct Division: Decodable {
    let id: Int
    let title: String
    let short: String

    enum CodingKeys: String, CodingKey {
        case id = "idDivision"
        case title = "titleDivision"
        case short = "shortTitle"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        short = try container.decode(String.self, forKey: .short)
    }
}
