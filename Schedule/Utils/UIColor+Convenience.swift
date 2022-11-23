//
//  Utils.swift
//  Schedule
//
//  Created by Egor Molchanov on 12.12.2021.
//

import UIKit
import CryptoKit

extension UIColor {
  convenience init?(for subject: String) {
    guard let data = subject.data(using: .utf8) else {
      return nil
    }
    let sha256 = SHA256.hash(data: data)
    let bytes: [UInt8] = sha256.suffix(3)
    self.init(
      red:   CGFloat(bytes[0]) / 255.0,
      green: CGFloat(bytes[1]) / 255.0,
      blue:  CGFloat(bytes[2]) / 255.0,
      alpha: 1.0)
  }
}
