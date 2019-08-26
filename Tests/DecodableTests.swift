//
//  DecodableTests.swift
//  Tests
//
//  Created by Егор Молчанов on 09/08/2019.
//  Copyright © 2019 Prismade. All rights reserved.
//

import XCTest
@testable import Schedule


class DecodableTest: XCTestCase {

    var decoder = JSONDecoder()

    let divisionJson = """
    {
        "idDivision": 26,
        "titleDivision": "Академия физической культуры и спорта",
        "shortTitle": "ФКС"
    }
    """.data(using: .utf8)!

    let courseJson = """
    {
        "kurs": 2
    }
    """.data(using: .utf8)!

    let groupJson = """
    {
        "title": "81АП",
        "idgruop": 6543,
        "Codedirection": "15.03.04 (п) (о)",
        "levelEducation": "бакалавриат"
    }
    """.data(using: .utf8)!

    let scheduleJson = """
        {
            "idGruop": 6344,
            "NumberSubGruop": 0,
            "TitleSubject": "Практика по получению первичных  профессиональных умений и навыков, в том числе первичных умений и навыков научно-исследовательской деятельности",
            "TypeLesson": "зачет",
            "NumberLesson": 1,
            "DayWeek": 5,
            "Korpus": "12",
            "NumberRoom": "320",
            "special": "Промышленная разработка программного обеспечения",
            "title": "81ПГ",
            "employee_id": 127,
            "Family": "Константинов",
            "Name": "Игорь",
            "SecondName": "Сергеевич"
        }
        """.data(using: .utf8)!


    func testDivisionJsonDecoding() {
        XCTAssertNoThrow(try decoder.decode(Division.self, from: divisionJson))
    }

    func testCourseJsonDecoding() {
        XCTAssertNoThrow(try decoder.decode(Course.self, from: courseJson))
    }

    func testGroupJsonDecoding() {
        XCTAssertNoThrow(try decoder.decode(Group.self, from: groupJson))
    }

    func testScheduleJsonDecoding() {
        XCTAssertNoThrow(try decoder.decode(Lesson.self, from: scheduleJson))
    }


}

