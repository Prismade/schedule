//
//  CalendarView.swift
//  Schedule
//
//  Created by Egor Molchanov on 23.11.2022.
//  Copyright © 2022 Prismade. All rights reserved.
//

import UIKit

enum SScrollDirection {
  case left
  case none
  case right
}

final class CalendarView: UIStackView {
  struct IndexPath {
    let weekOffset: Int
    let day: SWeekDay
  }
  
  lazy var weekdaysLabels: UIStackView = {
    let stack = UIStackView()
    stack.distribution = .fillEqually
    stack.setContentHuggingPriority(.defaultHigh, for: .vertical)
    var symbols = Calendar.current.shortStandaloneWeekdaySymbols
    symbols.removeFirst()
    
    for i in 0..<symbols.count {
      let label = UILabel()
      label.text = symbols[i]
      label.font = .systemFont(ofSize: 10.0)
      label.textAlignment = .center
      label.textColor = UIColor(named: i != (symbols.count - 1) ? "WorkingDayTitleText" : "DayOffTitleText")
      stack.addArrangedSubview(label)
    }
    
    return stack
  }()
  lazy var scrollView: UIScrollView = {
    let view = UIScrollView()
    view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
    view.clipsToBounds = true
    view.isPagingEnabled = true
    view.showsVerticalScrollIndicator = false
    view.showsHorizontalScrollIndicator = false
    view.bounces = false
    view.scrollsToTop = false
    view.delegate = self
    
    let previousWeekView = WeekView()
    previousWeekView.tag = 1
    previousWeekView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(previousWeekView)
    
    let currentWeekView = WeekView()
    currentWeekView.tag = 2
    currentWeekView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(currentWeekView)
    
    let nextWeekView = WeekView()
    nextWeekView.tag = 3
    nextWeekView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(nextWeekView)
    
    NSLayoutConstraint.activate([
      previousWeekView.leadingAnchor.constraint(equalTo: view.contentLayoutGuide.leadingAnchor),
      previousWeekView.topAnchor.constraint(equalTo: view.contentLayoutGuide.topAnchor),
      previousWeekView.bottomAnchor.constraint(equalTo: view.contentLayoutGuide.bottomAnchor),
      previousWeekView.widthAnchor.constraint(equalTo: view.frameLayoutGuide.widthAnchor, multiplier: 1.0),
      previousWeekView.heightAnchor.constraint(equalTo: view.frameLayoutGuide.heightAnchor, multiplier: 1.0),
      
      currentWeekView.leadingAnchor.constraint(equalTo: previousWeekView.trailingAnchor),
      currentWeekView.topAnchor.constraint(equalTo: view.contentLayoutGuide.topAnchor),
      currentWeekView.bottomAnchor.constraint(equalTo: view.contentLayoutGuide.bottomAnchor),
      currentWeekView.widthAnchor.constraint(equalTo: view.frameLayoutGuide.widthAnchor, multiplier: 1.0),
      currentWeekView.heightAnchor.constraint(equalTo: view.frameLayoutGuide.heightAnchor, multiplier: 1.0),
      
      nextWeekView.leadingAnchor.constraint(equalTo: currentWeekView.trailingAnchor),
      nextWeekView.topAnchor.constraint(equalTo: view.contentLayoutGuide.topAnchor),
      nextWeekView.trailingAnchor.constraint(equalTo: view.contentLayoutGuide.trailingAnchor),
      nextWeekView.bottomAnchor.constraint(equalTo: view.contentLayoutGuide.bottomAnchor),
      nextWeekView.widthAnchor.constraint(equalTo: view.frameLayoutGuide.widthAnchor, multiplier: 1.0),
      nextWeekView.heightAnchor.constraint(equalTo: view.frameLayoutGuide.heightAnchor, multiplier: 1.0),
    ])
    
    return view
  }()
  lazy var currentDateLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    return label
  }()
  
  var weekDaysForWeekOffset: ((Int) -> [Date])?
  var weekWasChanged: ((CalendarView, Int) -> Void)?
  var dayWasSelected: ((CalendarView, IndexPath) -> Void)?
  
  var weekOffset: Int = 0 {
    didSet {
      updateWeekDates()
      scrollView.setContentOffset(
        CGPoint(
          x: pageSize.width,
          y: scrollView.contentOffset.y),
        animated: false)
      previousPhysicalPage = currentPhysicalPage
      updateDateLabel()
    }
  }
  var selectedDay: SWeekDay = .monday {
    didSet {
      for week in scrollView.subviews {
        (week as! WeekView).selectedDay = selectedDay
      }
      updateDateLabel()
    }
  }
  var lastScrollDirection: SScrollDirection {
    if currentPhysicalPage == previousPhysicalPage {
      return .none
    } else if currentPhysicalPage > previousPhysicalPage {
      return .right
    } else {
      return .left
    }
  }
  
  private var didInstantiate = false
  private var pageSize: CGSize {
    return scrollView.frame.size
  }
  private var previousPhysicalPage = 0
  private var currentPhysicalPage: Int {
    let pageWidth = pageSize.width
    let currentOffset = scrollView.contentOffset.x
    return Int(currentOffset / pageWidth)
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
    axis = .vertical
    addArrangedSubview(weekdaysLabels)
    addArrangedSubview(scrollView)
    addArrangedSubview(currentDateLabel)
    for w in scrollView.subviews {
      (w as! WeekView).dayWasSelected = { day in
        self.selectedDay = day
        self.dayWasSelected?(
          self,
          IndexPath(weekOffset: self.weekOffset, day: self.selectedDay))
      }
    }
    setCustomSpacing(8.0, after: currentDateLabel)
  }
  
  // Call this after parent viewcontroller's did layout subviews
  func instantiateView(for selectedDay: SWeekDay = .monday) {
    guard !didInstantiate else { return }
    
    layoutIfNeeded()
    scrollView.setContentOffset(
      CGPoint(
        x: pageSize.width,
        y: scrollView.contentOffset.y),
      animated: false)
    weekOffset = 0
    self.selectedDay = selectedDay
    previousPhysicalPage = currentPhysicalPage
    didInstantiate = true
  }
  
  private func updateWeekDates() {
    guard let daysGetter = weekDaysForWeekOffset else { return }
    
    let prevWeek = scrollView.subviews.first(where: { $0.tag == 1 }) as! WeekView
    prevWeek.days = daysGetter(weekOffset - 1)
    let currWeek = scrollView.subviews.first(where: { $0.tag == 2 }) as! WeekView
    currWeek.days = daysGetter(weekOffset)
    let nextWeek = scrollView.subviews.first(where: { $0.tag == 3 }) as! WeekView
    nextWeek.days = daysGetter(weekOffset + 1)
  }
  
  private func updateDateLabel() {
    let date = (scrollView.subviews[1] as! WeekView).days[selectedDay.rawValue - 1]
    let formatter = DateFormatter()
    formatter.dateFormat = "d MMMM"
    
    let formatedDate = formatter.string(from: date)
    currentDateLabel.text = formatedDate
  }
}

extension CalendarView: UIScrollViewDelegate {
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    guard lastScrollDirection != .none else { return }
    if lastScrollDirection == .left {
      weekOffset -= 1
    } else if lastScrollDirection == .right {
      weekOffset += 1
    }
    weekWasChanged?(self, weekOffset)
  }
}
