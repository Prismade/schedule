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
        let timeStamp = createTimeStamp(for: weekOffset)
        let url = baseUrl + "//\(groupId)///\(timeStamp)/printschedule"
        return session.request(url).responseDecodable(completionHandler: completion)
    }

    // MARK: - Private Methods

    private func createTimeStamp(for weekOffset: Int) -> String {
        let date = Date()
        let calendar = Calendar(identifier: .gregorian)
        let time = Int(date.timeIntervalSince1970)
        let day = calendar.component(.weekday, from: date) - 1
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)

        var currentWeekStart = time + 86400000 - 86400000 * day
        currentWeekStart *= 1000 // because JavaScript is awesome!
        currentWeekStart = (currentWeekStart - (-180 * 60000)) - (3600 * hour + 60 * minute + (1 * second)) * 1000

        currentWeekStart = 1 * currentWeekStart + 604800000 * weekOffset

        return String(currentWeekStart)
    }


}
