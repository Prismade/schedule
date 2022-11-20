//
//  Endpoint.swift
//  Schedule
//
//  Created by Egor Molchanov on 12.12.2021.
//  Copyright © 2022 Prismade. All rights reserved.
//

import Foundation

protocol Endpoint: CustomDebugStringConvertible {
  static var baseUrl: URL? { get }
  var fullUrl: URL? { get }
}

extension Endpoint {
  var debugDescription: String {
    "[Request] GET:\n\t\(fullUrl?.absoluteString ?? "")\n"
  }
}
