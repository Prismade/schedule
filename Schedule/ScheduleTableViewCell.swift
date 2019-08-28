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

    func configure(with lesson: Lesson?) {
        if let lesson = lesson {
            number.text = String(lesson.number)
            subject.text = lesson.subject

            if lesson.special != "" {
                special.isHidden = false
                special.text = "(\(lesson.special))"
            } else {
                special.isHidden = true
            }

            type.isHidden = false
            type.text = "(\(lesson.type))"

            if lesson.employeeName != "" {
                teacher.isHidden = false
                teacher.text = lesson.employeeName
            } else {
                teacher.isHidden = true
            }

            location.isHidden = false
            location.text = lesson.location
        } else {
            number.text = " "
            subject.text = "Пар нет"
            special.isHidden = true
            type.isHidden = true
            teacher.isHidden = true
            location.isHidden = true
        }
    }


}
