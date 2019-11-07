//
//  SettingsTableViewController.swift
//  Schedule
//
//  Created by Егор Молчанов on 19/09/2019.
//  Copyright © 2019 Prismade. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var fullViewSwitch: UISwitch!
    @IBOutlet weak var scrollSwitch: UISwitch!
    @IBOutlet weak var swipeWeekSwitch: UISwitch!
    @IBOutlet weak var scrollSwitchLabel: UILabel!

    @IBAction func fullViewSwitchToggled(_ sender: UISwitch) {
        let defaults = UserDefaults.standard
        defaults.set(sender.isOn, forKey: "fullView")
    }

    @IBAction func scrollSwitchToggled(_ sender: UISwitch) {
        let defaults = UserDefaults.standard
        defaults.set(sender.isOn, forKey: "scrollToToday")
    }

    @IBAction func swipeWeekSwitchToggle(_ sender: UISwitch) {
        let defaults = UserDefaults.standard
        defaults.set(sender.isOn, forKey: "swipeWeek")
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        let defaults = UserDefaults.standard
        fullViewSwitch.isOn = defaults.bool(forKey: "fullView")
        scrollSwitch.isOn = defaults.bool(forKey: "scrollToToday")
        swipeWeekSwitch.isOn = defaults.bool(forKey: "swipeWeek")

        clearsSelectionOnViewWillAppear = true
    }

    @objc private func scrollSwitchLabelClicked(_ sender: Any) {

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (section) {
        case 0: return 1;
        case 1: return 3;
        default: return 0;
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 && indexPath.section == 0 {
            performSegue(withIdentifier: "toStartSettings", sender: nil)
        }
    }


}
