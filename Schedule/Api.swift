//
//  RestClient.swift
//  schedule
//
//  Created by Егор Молчанов on 07/08/2019.
//  Copyright © 2019 Prismade. All rights reserved.
//

import Foundation
import Alamofire


final class Api {

    // MARK: - Static Properties

    static let shared = Api()

    // MARK: - Private Properties

    private let session = Alamofire.Session()
    private let baseUrl = "http://oreluniver.ru/schedule"

    // MARK: - Initializers

    private init() {}

    // MARK: - Public Methods

    @discardableResult
    func getDivisions(completion: @escaping (DataResponse<[Division]>) -> Void) -> Request {
        let url = baseUrl + "/divisionlistforstuds"
        return session.request(url).responseDecodable(completionHandler: completion)
    }

    @discardableResult
    func getCourses(for division: Int, completion: @escaping (DataResponse<[Course]>) -> Void) -> Request  {
        let url = baseUrl + "/\(division)/kurslist"
        return session.request(url).responseDecodable(completionHandler: completion)
    }

    @discardableResult
    func getGroups(for course: Int, at division: Int, completion: @escaping (DataResponse<[Group]>) -> Void) -> Request  {
        let url = baseUrl + "/\(division)/\(course)/grouplist"
        return session.request(url).responseDecodable(completionHandler: completion)
    }

    @discardableResult
    func getSchedule(for groupId: Int, on weekOffset: Int, completion: @escaping (DataResponse<[Lesson]>) -> Void) -> Request  {
        let timeStamp: String = createApiTimeStamp(for: weekOffset)
        let url = baseUrl + "//\(groupId)///\(timeStamp)/printschedule"
        return session.request(url).responseDecodable(completionHandler: completion)
    }

    func getWeekBoundaries(for weekOffset: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"

        let monday = createTimeStamp(for: weekOffset)
        let mondayDate = Date(timeIntervalSince1970: Double(monday))

        let sunday = monday + 518400
        let sundayDate = Date(timeIntervalSince1970: Double(sunday))

        return "\(formatter.string(from: mondayDate))-\(formatter.string(from: sundayDate))"
    }

    func createApiTimeStamp(for weekOffset: Int) -> String {
        let timeStamp = createTimeStamp(for: weekOffset)
        return String(timeStamp * 1000)
    }

    func createTimeStamp(for weekOffset: Int) -> Int {
        let date = Date()
        var calendar = Calendar(identifier: .gregorian)
        calendar.firstWeekday = 2
        var components = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: date)
        components.weekday = 2
        let monday = calendar.date(from: components)!
        let mondayWithOffset = Int(monday.timeIntervalSince1970) + weekOffset * 604800
        return mondayWithOffset
    }

    func getTimeForLesson(_ number: Int) -> String {
        switch number {
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


}
