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

    // MARK: - Private Properties

    private var istoggledFull = false

    // MARK: - Public Methods

    func configure(with lesson: Lesson?) {
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

            if lesson.subgroup != 0 {
                subgroup.text = String(lesson.subgroup)
            } else {
                subgroup.text = ""
            }
            subgroup.isHidden = true

            time.text = Api.shared.getTimeForLesson(lesson.number)
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
    }

    func toggleFullInformation(with lesson: Lesson?) {
        if let lesson = lesson {
            if special.text != "" {
                special.isHidden = !special.isHidden
            }

            if subgroup.text != "" {
                subgroup.isHidden = !subgroup.isHidden
            }

            time.isHidden = !time.isHidden
            if istoggledFull {
                teacher.text = lesson.employeeName
            } else {
                teacher.text = lesson.fullEmployeeName
            }

        }
        istoggledFull = !istoggledFull
    }


}
