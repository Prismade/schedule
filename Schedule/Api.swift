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

    @discardableResult func getDivisions(completion: @escaping (DataResponse<[Division], AFError>) -> Void) -> Request {
        let url = baseUrl + "/divisionlistforstuds"
        return session.request(url).responseDecodable(completionHandler: completion)
    }

    @discardableResult func getCourses(for division: Int, completion: @escaping (DataResponse<[Course], AFError>) -> Void) -> Request  {
        let url = baseUrl + "/\(division)/kurslist"
        return session.request(url).responseDecodable(completionHandler: completion)
    }

    @discardableResult func getGroups(for course: Int, at division: Int, completion: @escaping (DataResponse<[Group], AFError>) -> Void) -> Request  {
        let url = baseUrl + "/\(division)/\(course)/grouplist"
        return session.request(url).responseDecodable(completionHandler: completion)
    }

    @discardableResult func getSchedule(for groupId: Int, on weekOffset: Int, completion: @escaping (DataResponse<[Lesson], AFError>) -> Void) -> Request  {
        let timeStamp: String = TimeManager.shared.createApiTimeKey(for: weekOffset)
        let url = baseUrl + "//\(groupId)///\(timeStamp)/printschedule"
        return session.request(url).responseDecodable(completionHandler: completion)
    }


}
