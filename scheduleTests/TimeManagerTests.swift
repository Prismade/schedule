//
//  TimeManagerTests.swift
//  scheduleTests
//
//  Created by Егор Молчанов on 02.11.2019.
//  Copyright © 2019 prismade. All rights reserved.
//

import XCTest

@testable
import schedule

class TimeManagerTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssert(TimeManager.shared.getTimeBoundaries(for: 1) == "8:30-10:00")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
