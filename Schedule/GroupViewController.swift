//
//  GroupViewController.swift
//  Schedule
//
//  Created by Егор Молчанов on 23/08/2019.
//  Copyright © 2019 Prismade. All rights reserved.
//

import UIKit

class GroupViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var table: UITableView!

    // MARK: - Private Properties

    private let refreshControl = UIRefreshControl()
    private var groupList = [Group]() {
        didSet {
            refreshControl.endRefreshing()
            table.reloadData()
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        table.dataSource = self
        table.delegate = self
        table.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        refreshControl.beginRefreshing()
        loadData()
    }

    // MARK: - Public Methods

    @objc func refresh(_ sender: Any) {
        loadData()
    }

    func loadData() {
        let defaults = UserDefaults.standard
        let division = defaults.integer(forKey: "division")
        let course = defaults.integer(forKey: "course")

        Api.shared.getGroups(for: course, at: division) { response in
            switch response.result {
            case .success(let data): self.groupList = data
            case .failure(let error): print(error)
            }
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = table.indexPathForSelectedRow {
            let defaults = UserDefaults.standard
            defaults.set(groupList[indexPath.row].id, forKey: "group")
            defaults.set(true, forKey: "introPassed")
        }
    }
}

// MARK: - Extensions

extension GroupViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "GroupCell")!
        cell.textLabel?.text = groupList[indexPath.row].title
        return cell
    }
}


extension GroupViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toSchedule", sender: nil)
    }
}
