//
//  ApiTests.swift
//  Tests
//
//  Created by Егор Молчанов on 10/08/2019.
//  Copyright © 2019 Prismade. All rights reserved.
//

import XCTest
@testable import Schedule

class ApiTests: XCTestCase {
    var expectation: XCTestExpectation!

    override func setUp() {
        expectation = expectation(description: "Testing async operation")
        expectation.expectedFulfillmentCount = 1
    }

    func testGetDivisions() {
        Api.shared.getDivisions() { [weak self] result in
            if let res = result.data {
                print(res)
                self?.expectation.fulfill()
            } else {
                XCTFail("Your code sucks!")
            }
        }

        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("testGetDivisions failed with message:\n\(error)")
            }
        }
    }

    func testGetCourses() {
        Api.shared.getCourses(for: 7) { [weak self] result in
            if let res = result.data {
                print(res)
                self?.expectation.fulfill()
            } else {
                XCTFail("Your code sucks!")
            }
        }

        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("testGetCourses failed with message:\n\(error)")
            }
        }
    }

    func testGetGroups() {
        Api.shared.getGroups(for: 3, at: 7)  { [weak self] result in
            if let res = result.data {
                print(res)
                self?.expectation.fulfill()
            } else {
                XCTFail("Your code sucks!")
            }
        }

        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("testGetGroups failed with message:\n\(error)")
            }
        }
    }

    func testGetSchedule() {
        Api.shared.getSchedule(for: 4096, on: -12) { [weak self] result in
                if let res = result.data {
                    print(res)
                    self?.expectation.fulfill()
                } else {
                    XCTFail("Your code sucks!")
                }
        }

        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("testWeekOffset failed with message:\n\(error)")
            }
        }
    }


}
