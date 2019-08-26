//
//  CourseViewController.swift
//  Schedule
//
//  Created by Егор Молчанов on 23/08/2019.
//  Copyright © 2019 Prismade. All rights reserved.
//

import UIKit

class CourseViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var table: UITableView!

    // MARK: - Public Properties

    var division: Division?

    // MARK: - Private Properties

    private let refreshControl = UIRefreshControl()
    private var courseList = [Course]() {
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
        Api.shared.getCourses(for: division!.id) { response in
            switch response.result {
            case .success(let data): self.courseList = data
            case .failure(let error): print(error)
            }
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationView = segue.destination as? GroupViewController{
            if let indexPath = table.indexPathForSelectedRow {
                destinationView.division = division
                destinationView.course = courseList[indexPath.row]
            }
        }
    }


}

// MARK: - Extensions

extension CourseViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courseList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "CourseCell")!
        cell.textLabel?.text = String(courseList[indexPath.row].course)
        return cell
    }
}


extension CourseViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "toGroup", sender: nil)
    }
}
