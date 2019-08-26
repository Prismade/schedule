//
//  Course.swift
//  Schedule
//
//  Created by Егор Молчанов on 10/08/2019.
//  Copyright © 2019 Prismade. All rights reserved.
//

import Foundation


struct Course: Decodable {
    let course: Int

    enum CodingKeys: String, CodingKey {
        case course = "kurs"
    }

    init(decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        course = try container.decode(Int.self, forKey: .course)
    }
}
