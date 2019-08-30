//
//  DivisionViewController.swift
//  Schedule
//
//  Created by Егор Молчанов on 23/08/2019.
//  Copyright © 2019 Prismade. All rights reserved.
//

import UIKit

class DivisionViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var table: UITableView!

    // MARK: - Private Properties

    private let refreshControl = UIRefreshControl()
    private var divisionList = [Division]() {
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
        Api.shared.getDivisions() { response in
            switch response.result {
            case .success(let data): self.divisionList = data
            case .failure(let error): print(error)
            }
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = table.indexPathForSelectedRow {
            let defaults = UserDefaults.standard
            defaults.set(divisionList[indexPath.row].id, forKey: "division")
        }
    }

}

// MARK: - Extensions

extension DivisionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return divisionList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "DivisionCell")!
        cell.textLabel?.text = divisionList[indexPath.row].short
        return cell
    }
}


extension DivisionViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toCourse", sender: nil)
    }
}
