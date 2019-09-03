//
//  ScheduleViewController.swift
//  schedule
//
//  Created by Егор Молчанов on 20/07/2019.
//  Copyright © 2019 Prismade. All rights reserved.
//

import UIKit


final class ScheduleViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var settingsButton: UIBarButtonItem!

    // MARK: - IBActions

    @IBAction func nextButtonCkick(_ sender: UIBarButtonItem) {
        weekOffset += 1
        updateModel(for: weekOffset)
    }

    @IBAction func currentWeekButtonClick(_ sender: UIBarButtonItem) {
        weekOffset = 0
        updateModel(for: weekOffset)
    }

    @IBAction func backButtonClick(_ sender: UIBarButtonItem) {
        weekOffset -= 1
        updateModel(for: weekOffset)
    }

    @IBAction func onSettingsButtonClick(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "backToStart", sender: nil)
    }

    // MARK: - Private Properties

    private let viewModel = ScheduleViewModel()
    private let refreshControl = UIRefreshControl()
    private var weekOffset: Int = 0

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = viewModel
        table.register(UINib(nibName: "ScheduleTableViewCell", bundle: nil), forCellReuseIdentifier: "ScheduleCell")
        table.refreshControl = refreshControl

        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)

        viewModel.dataUpdateDidFinishSuccessfully = {
            self.refreshControl.endRefreshing()
            self.table.reloadData()
            self.animateTableUpdate(hide: false)
            self.updateWeekDates(on: self.weekOffset)
        }

        updateModel(for: weekOffset)
    }

    // MARK: - Private Methods

    @objc private func refresh(_ sender: Any) {
        updateModel(for: weekOffset)
    }

    private func updateModel(for weekOffset: Int) {
        let defaults = UserDefaults.standard
        let group = defaults.integer(forKey: "group")
        refreshControl.beginRefreshing()
        animateTableUpdate(hide: true)
        viewModel.update(for: group, on: weekOffset)
    }

    private func updateWeekDates(on weekOffset: Int) {
        navigationItem.title = "\(Api.shared.getWeekBoundaries(for: weekOffset))"
    }

    private func animateTableUpdate(hide: Bool) {
        if hide {
            table.isHidden = true
        } else {
            UIView.transition(with: table, duration: 0.5, options: [.allowAnimatedContent, .showHideTransitionViews, .transitionCrossDissolve], animations: {
                self.table.isHidden = false
            })
        }

    }


}
