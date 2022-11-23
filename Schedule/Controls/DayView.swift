//
//  DayView.swift
//  Schedule
//
//  Created by Egor Molchanov on 23.11.2022.
//  Copyright © 2022 Prismade. All rights reserved.
//

import UIKit

final class DayView: UIView {
  lazy var dayLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.textAlignment = .center
    label.layer.cornerRadius = CGFloat(cornerRadius)
    label.clipsToBounds = true
    NSLayoutConstraint.activate([
      label.widthAnchor.constraint(greaterThanOrEqualToConstant: 40.0),
      label.widthAnchor.constraint(equalTo: label.heightAnchor, multiplier: 1.0)
    ])
    return label
  }()
  
  var dayOff: Bool = false {
    didSet {
      if selected {
        dayLabel.textColor = UIColor(named: "DaySelectedText")
      } else {
        if dayOff {
          dayLabel.textColor = UIColor(named: "DayOffText")
        } else {
          dayLabel.textColor = UIColor(named: "WorkingDayText")
        }
      }
    }
  }
  var selected: Bool = false {
    didSet {
      if selected {
        dayLabel.backgroundColor = UIColor(named: "DaySelectedBackground")
        dayLabel.textColor = UIColor(named: "DaySelectedText")
      } else {
        dayLabel.backgroundColor = UIColor(named: "DayBackground")
        if dayOff {
          dayLabel.textColor = UIColor(named: "DayOffText")
        } else {
          dayLabel.textColor = UIColor(named: "WorkingDayText")
        }
      }
    }
  }
  var cornerRadius: Float = 20.0 {
    didSet {
      dayLabel.layer.cornerRadius = CGFloat(cornerRadius)
    }
  }
  var text: String = "0" {
    didSet {
      dayLabel.text = text
    }
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    commonInit()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  convenience init() {
    self.init(frame: .zero)
  }
  
  private func commonInit() {
    addSubview(dayLabel)
    NSLayoutConstraint.activate([
      dayLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
      dayLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
    ])
  }
}
