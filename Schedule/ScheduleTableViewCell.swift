//
//  ScheduleTableViewCell.swift
//  schedule
//
//  Created by Егор Молчанов on 20/07/2019.
//  Copyright © 2019 Prismade. All rights reserved.
//

import UIKit

final class ScheduleTableViewCell: UITableViewCell {

    // MARK: - IBOutlets

    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var subject: UILabel!
    @IBOutlet weak var special: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var teacher: UILabel!
    @IBOutlet weak var location: UILabel!

    // MARK: - Public Methods

    func configure(with lesson: Lesson) {
        number.text = String(lesson.number)
        subject.text = lesson.subject
        if lesson.special != "" {
            special.text = "(\(lesson.special))"
        } else {
            special.isHidden = true
        }
        type.text = "(\(lesson.type))"
        if lesson.employeeName != "" {
            teacher.text = lesson.employeeName
        } else {
            teacher.isHidden = true
        }

        location.text = lesson.location
    }


}
