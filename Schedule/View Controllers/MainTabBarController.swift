//
//  MainTabBarController.swift
//  Schedule
//
//  Created by Egor Molchanov on 23.11.2022.
//  Copyright © 2022 Prismade. All rights reserved.
//

import UIKit

final class MainTabBarController: UITabBarController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let scheduleViewController = SStudentScheduleViewController()
    let scheduleNavigationController = UINavigationController(rootViewController: scheduleViewController)
    scheduleNavigationController.navigationBar.tintColor = UIColor(named: "MainAccentColor")
    scheduleNavigationController.tabBarItem = UITabBarItem(
      title: "Пары",
      image: UIImage(systemName: "magazine.fill"),
      tag: 0)
    
    let examsViewController = SExamsTableViewController(style: .grouped)
    let examsNavigationController = UINavigationController(rootViewController: examsViewController)
    examsNavigationController.navigationBar.tintColor = UIColor(named: "MainAccentColor")
    examsNavigationController.tabBarItem = UITabBarItem(
      title: "Экзамены",
      image: UIImage(systemName: "doc.text.fill"),
      tag: 1)
    
    setViewControllers(
      [scheduleNavigationController, examsNavigationController],
      animated: false)
    
    tabBar.tintColor = UIColor(named: "MainAccentColor")
  }
}
