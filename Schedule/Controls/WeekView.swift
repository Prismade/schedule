//
//  WeekView.swift
//  Schedule
//
//  Created by Egor Molchanov on 23.11.2022.
//  Copyright © 2022 Prismade. All rights reserved.
//

import UIKit

final class WeekView: UIStackView {
  var dayViews: [DayView] = []
  var dayWasSelected: ((SWeekDay) -> Void)?
  var selectedDay: SWeekDay = .monday {
    didSet {
      dayViews.first(where: { $0.tag == oldValue.rawValue })?.selected = false
      dayViews.first(where: { $0.tag == selectedDay.rawValue })?.selected = true
    }
  }
  var days = [Date]() {
    didSet {
      for i in 0..<days.count {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("d")
        let texts = days.map {
          dateFormatter.string(from: $0)
        }
        dayViews.first(where: { $0.tag == i + 1 })?.text = texts[i]
      }
    }
  }
  
  required init(coder: NSCoder) {
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
    distribution = .fillEqually
    
    for i in 1...6 {
      let day = DayView()
      day.tag = i
      day.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(_:))))
      dayViews.append(day)
      addArrangedSubview(day)
    }
  }
  
  @objc
  private func handleTap(_ sender: UITapGestureRecognizer) {
    if sender.state == .ended {
      selectedDay = SWeekDay(rawValue: sender.view!.tag)!
      dayWasSelected?(selectedDay)
    }
  }
}
