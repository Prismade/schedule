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
    
    let scheduleViewController = UIStoryboard(name: "StudentSchedule", bundle: nil)
      .instantiateInitialViewController()
    scheduleViewController?.tabBarItem = UITabBarItem(
      title: "Пары",
      image: UIImage(systemName: "magazine.fill"),
      tag: 0)
    
    let examsViewController = SExamsTableViewController(style: .grouped)
    let examsNavigationController = UINavigationController(rootViewController: examsViewController)
    examsNavigationController.tabBarItem = UITabBarItem(
      title: "Экзамены",
      image: UIImage(systemName: "doc.text.fill"),
      tag: 1)
    
    setViewControllers(
      [scheduleViewController ?? UIViewController(), examsNavigationController],
      animated: false)
    
    tabBar.tintColor = UIColor(named: "MainAccentColor")
  }
}
