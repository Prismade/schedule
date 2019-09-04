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
    @IBOutlet weak var subgroup: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var teacher: UILabel!
    @IBOutlet weak var location: UILabel!

    // MARK: - Public Methods

    func configure(with lesson: Lesson?, toggled: Bool) {
        if let lesson = lesson {
            number.text = String(lesson.number)
            subject.text = lesson.subject

            if lesson.special != "" {
                special.text = "(\(lesson.special))"
                special.isHidden = false
            } else {
                special.text = ""
                special.isHidden = true
            }

            type.text = "(\(lesson.type))"
            type.isHidden = false
            subgroup.isHidden = true
            time.isHidden = true

            if lesson.employeeName != "" {
                teacher.isHidden = false
                teacher.text = lesson.employeeName
            } else {
                teacher.isHidden = true
            }

            location.text = lesson.location
            location.isHidden = false
        } else {
            number.text = " "
            subject.text = "Пар нет"
            special.isHidden = true
            type.isHidden = true
            subgroup.isHidden = true
            time.isHidden = true
            teacher.isHidden = true
            location.isHidden = true
        }
        update(with: lesson, toggled: !toggled)
    }

    func update(with lesson: Lesson?, toggled: Bool) {
        if let lesson = lesson {
            if toggled {
                special.isHidden = true
                subgroup.isHidden = true
                time.isHidden = true
                teacher.text = lesson.employeeName
            } else {
                if special.text != "" {
                    special.isHidden = false
                }

                if lesson.subgroup != 0 {
                    subgroup.text = String("Подгруппа \(lesson.subgroup)")
                    subgroup.isHidden = false
                } else {
                    subgroup.isHidden = true
                }

                time.text = Api.shared.getTimeForLesson(lesson.number)
                time.isHidden = false
                teacher.text = lesson.fullEmployeeName
            }
        }
    }


}
