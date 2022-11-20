//
//  OreluniverEndpoint.swift
//  Schedule
//
//  Created by Egor Molchanov on 12.12.2021.
//  Copyright © 2022 Prismade. All rights reserved.
//

import Foundation

enum Oreluniver {
  case divisions
  case courses(division: Int)
  case groups(division: Int, course: Int)
  case schedule(group: Int, weeksFromNow: Int)
  case exams(group: Int)
  case employee(identifier: Int)
  case buildings
  
  var methodString: String {
    switch self {
    case .divisions:
      return "/schedule/divisionlistforstuds"
    case .courses(let division):
      return "/schedule/\(division)/kurslist"
    case .groups(let division, let course):
      return "/schedule/\(division)/\(course)/grouplist"
    case .schedule(let group, let weeksFromNow):
      let timestamp = STimeManager.shared.getApiKey(for: weeksFromNow)
      return "/schedule//\(group)///\(timestamp)/printschedule"
    case .exams(let group):
      return "/schedule/\(group)////printexamschedule"
    case .employee(let identifier):
      return "/employee/\(identifier)"
    case .buildings:
      return "/assets/js/buildings.json"
    }
  }
}

extension Oreluniver: Endpoint {
  static var baseUrl: URL? {
    URL(string: "https://oreluniver.ru")
  }
  
  var fullUrl: URL? {
    URL(string: methodString, relativeTo: Oreluniver.baseUrl)
  }
}
