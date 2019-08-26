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

    // MARK: - Public Properties

    var group: Group?

    // MARK: - Private Properties

    private let viewModel = ScheduleViewModel()
    private let refreshControl = UIRefreshControl()
    private var weekOffset: Int = 0

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.viewControllers.removeFirst(
            (self.navigationController?.viewControllers.count)! - 1)

        table.dataSource = viewModel
        table.register(UINib(nibName: "ScheduleTableViewCell", bundle: nil), forCellReuseIdentifier: "ScheduleCell")
        table.refreshControl = refreshControl

        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        refreshControl.beginRefreshing()

        viewModel.dataUpdateDidFinishSuccessfully = {
            self.refreshControl.endRefreshing()
            self.table.reloadData()
        }
        viewModel.update(for: group!.id, on: weekOffset)
    }

    // MARK: - Public Methods

    @objc func refresh(_ sender: Any) {
        updateModel(for: weekOffset)
    }

    // MARK: - Private Methods

    func updateModel(for weekOffset: Int) {
        refreshControl.beginRefreshing()
        viewModel.update(for: group!.id, on: weekOffset)
    }


}
