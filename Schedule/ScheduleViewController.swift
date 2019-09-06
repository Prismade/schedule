//
//  ScheduleViewController.swift
//  schedule
//
//  Created by Егор Молчанов on 20/07/2019.
//  Copyright © 2019 Prismade. All rights reserved.
//

import UIKit


final class ScheduleViewController: UIViewController {

    enum TableUpdateAnimationType {
        case hide
        case show
    }

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
    private let swipeRightRecognizer = UIScreenEdgePanGestureRecognizer()
    private let swipeLeftRecognizer = UIScreenEdgePanGestureRecognizer()
    private var weekOffset: Int = 0

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = viewModel
        table.delegate = viewModel
        table.register(UINib(nibName: "ScheduleTableViewCell", bundle: nil), forCellReuseIdentifier: "ScheduleCell")
        table.refreshControl = refreshControl

        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)

        swipeRightRecognizer.addTarget(self, action: #selector(swipeFromRightEdge(_:)))
        swipeRightRecognizer.edges = UIRectEdge.right

        swipeLeftRecognizer.addTarget(self, action: #selector(swipeFromLeftEdge(_:)))
        swipeLeftRecognizer.edges = UIRectEdge.left

        table.addGestureRecognizer(swipeRightRecognizer)
        table.addGestureRecognizer(swipeLeftRecognizer)

        viewModel.dataUpdateDidFinishSuccessfully = {
            self.refreshControl.endRefreshing()
            self.table.reloadData()
            self.animateTableUpdate(animation: .show)
            self.updateWeekDates(on: self.weekOffset)
        }

        updateModel(for: weekOffset)
    }

    // MARK: - Private Methods

    @objc private func refresh(_ sender: Any) {
        updateModel(for: weekOffset)
    }

    @objc private func swipeFromLeftEdge(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        if gestureRecognizer.state == .recognized {
            weekOffset -= 1
            updateModel(for: weekOffset)
        }
    }

    @objc private func swipeFromRightEdge(_ gestureRecognizer: UIScreenEdgePanGestureRecognizer) {
        if gestureRecognizer.state == .recognized {
            weekOffset += 1
            updateModel(for: weekOffset)
        }
    }

    private func updateModel(for weekOffset: Int) {
        let defaults = UserDefaults.standard
        let group = defaults.integer(forKey: "group")
        refreshControl.beginRefreshing()
        animateTableUpdate(animation: .hide)
        viewModel.update(for: group, on: weekOffset)
    }

    private func updateWeekDates(on weekOffset: Int) {
        navigationItem.title = "\(Api.shared.getWeekBoundaries(for: weekOffset))"
    }

    private func animateTableUpdate(animation: TableUpdateAnimationType) {
        switch animation {
        case .hide: table.isHidden = true
        case .show: UIView.transition(with: table, duration: 0.5, options: [.allowAnimatedContent, .showHideTransitionViews, .transitionCrossDissolve], animations: {
            self.table.isHidden = false
        })
        }
    }


}
