//
//  TimeManager.swift
//  Schedule
//
//  Created by Егор Молчанов on 24/09/2019.
//  Copyright © 2019 Prismade. All rights reserved.
//

import Foundation

protocol TimeManagement {
    func getWeekBoundaries(for weekOffset: Int) -> String
    func createApiTimeKey(for weekOffset: Int) -> String
    func createTimeStamp(for weekOffset: Int) -> Int
    func getTime(for lesson: Int) -> String
    func getCurrentLessonNumber() -> Int
    func getCurrentWeekDay() -> Int
}

final class TimeManager: TimeManagement {

    // MARK: - Public Properties

    static let shared = TimeManager()

    // MARK: - Initializers

    private init() {}

    // MARK: - Public Methods

    func getWeekBoundaries(for weekOffset: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"

        let monday = createTimeStamp(for: weekOffset)
        let mondayDate = Date(timeIntervalSince1970: Double(monday))

        let sunday = monday + 518400
        let sundayDate = Date(timeIntervalSince1970: Double(sunday))

        return "\(formatter.string(from: mondayDate))-\(formatter.string(from: sundayDate))"
    }

    func createApiTimeKey(for weekOffset: Int) -> String {
        let timeStamp = createTimeStamp(for: weekOffset)
        return String(timeStamp * 1000)
    }

    func createTimeStamp(for weekOffset: Int) -> Int {
        let date = Date()
        let calendar = Calendar(identifier: .gregorian)
        var components = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: date)
        components.weekday = 2
        let monday = calendar.date(from: components)!
        let mondayWithOffset = Int(monday.timeIntervalSince1970) + weekOffset * 604800
        return mondayWithOffset
    }

    func getTime(for lesson: Int) -> String {
        switch lesson {
        case 1:
            return "8:30-10:00"
        case 2:
            return "10:10-11:40"
        case 3:
            return "12:00-13:30"
        case 4:
            return "13:40-15:10"
        case 5:
            return "15:20-16:50"
        case 6:
            return "17:00-18:30"
        case 7:
            return "18:40-20:10"
        case 8:
            return "20:15-21:45"
        default:
            return ""
        }
    }

    func getCurrentLessonNumber() -> Int {
        let lessonsStartTimeInMinutes =
            [10 * 60, 11 * 60 + 40, 13 * 60 + 30,
             15 * 60 + 10, 16 * 60 + 50, 18 * 60 + 30,
             20 * 60 + 10, 24 * 60]
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.hour, .minute], from: Date())
        let timeInMinutes = components.hour! * 60 + components.minute!
        return lessonsStartTimeInMinutes.firstIndex() { timeInMinutes < $0 }!
    }

    func getCurrentWeekDay() -> Int {
        return Calendar(identifier: .gregorian).dateComponents([.weekday], from: Date()).weekday! - 2
    }


}
