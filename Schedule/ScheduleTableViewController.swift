//
//  ScheduleTableViewController.swift
//  schedule
//
//  Created by Егор Молчанов on 20/07/2019.
//  Copyright © 2019 Prismade. All rights reserved.
//

import UIKit


final class ScheduleViewController: UIViewController {

    @IBOutlet weak var table: UITableView!
    var viewModel: ScheduleTableViewModel?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    private func createViewModel(for weekOffset: Int) -> ScheduleTableViewModel {
//        Api.shared.getSchedule(for: 4930, weekOffset: -8) { response in
//            switch response.result {
//            case .success(let result): return ScheduleTableViewModel(data: result)
//            case .failure(let err): print("Yor code sucks! And that's why: \(err)")
//            }
//        }
    }


}


extension ScheduleViewController: ScheduleTableViewModelDelegate {
    func onRequestFailure(with error: Error) {
        <#code#>
    }

    func onRequestSuccess(with response: [Lesson]) {
        viewModel = ScheduleTableViewModel(data: d)
    }


}

