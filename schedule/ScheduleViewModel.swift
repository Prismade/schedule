import Foundation
import UIKit
import Alamofire


final class ScheduleViewModel: NSObject {

    enum WeekDay: Int {
        case monday = 1
        case tuesday = 2
        case wednesday = 3
        case thursday = 4
        case friday = 5
        case saturday = 6
    }

    final class ScheduleDay {
        let weekday: WeekDay
        let sectionTitle: String
        let lessons: [Lesson]
        var toggled: [Bool]
        var rowsNumber: Int {
            return lessons.count
        }

        init(weekday: WeekDay, lessons: [Lesson], isToggled: Bool) {
            self.weekday = weekday
            switch weekday {
            case .monday: self.sectionTitle = "Понедельник"
            case .tuesday: self.sectionTitle = "Вторник"
            case .wednesday : self.sectionTitle = "Среда"
            case .thursday : self.sectionTitle = "Четверг"
            case .friday : self.sectionTitle = "Пятница"
            case .saturday : self.sectionTitle = "Суббота"
            }
            self.lessons = lessons
            self.toggled = Array(repeating: isToggled, count: self.lessons.count)
        }
    }

    // MARK: - Public Properties

    var dataUpdateDidFinishSuccessfully: (() -> Void)?
    var dataUpdateDidFinishWithFailure: (() -> Void)?

    // MARK: - Private Properties

    private var schedule = [ScheduleDay]()
    private var didScrollToCurrentLesson = false

    // MARK: - Public Methods

    func update(for group: Int, on weekOffset: Int) {
        ApiManager.shared.getStudentSchedule(for: group, on: weekOffset) { response in
            switch response.result {
            case .success(let result): DispatchQueue.main.async {
                self.requestSucceeded(with: result)
                }
            case .failure(let error): DispatchQueue.main.async {
                self.requestFailed(with: error, and: response)
                }
            }
        }
    }

    func lesson(at position: (day: Int, number: Int)) -> Lesson? {
        let (day, number) = position
        if number >= schedule[day].lessons.count {
            return nil
        } else {
            return schedule[day].lessons[number]
        }
    }

    func scheduleDay(at day: Int) -> ScheduleDay {
        return schedule[day]
    }

    func isToggled(at position: (day: Int, number: Int)) -> Bool {
        let (day, number) = position
        if number >= schedule[day].lessons.count {
            return false
        } else {
            return schedule[day].toggled[number]
        }
    }

    func toggle(at position: (day: Int, number: Int)) {
        let (day, number) = position
        if number < schedule[day].lessons.count {
            schedule[day].toggled[number] = !schedule[day].toggled[number]
        }
    }

    // MARK: - Private Methods

    private func requestSucceeded(with response: [Lesson]) {
        let defaults = UserDefaults.standard
        schedule = (1...6).map { weekDay in
            ScheduleDay(weekday: WeekDay(rawValue: weekDay)!, lessons: response.filter { $0.weekDay == weekDay ? true : false }.sorted(), isToggled: defaults.bool(forKey: "fullView"))
        }
        guard let callback = dataUpdateDidFinishSuccessfully else { return }
        callback()
    }

    private func requestFailed(with error: Error, and response: DataResponse<[Lesson], AFError>) {
        print(error)
        print(response)
    }


}

// MARK: - Extensions

extension ScheduleViewModel: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return schedule.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return scheduleDay(at: section).sectionTitle
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let number = scheduleDay(at: section).rowsNumber
        if number == 0 {
            return 1 // for a cell, that tells there are no lessons
        } else {
            return number
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleTableCell", for: indexPath) as! ScheduleTableViewCell
        cell.configure(with: lesson(at: (indexPath.section, indexPath.row)), toggled: isToggled(at: (indexPath.section, indexPath.row)))
        cell.selectionStyle = .none
        return cell
    }


}


extension ScheduleViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ScheduleTableViewCell

        cell.update(with: lesson(at: (indexPath.section, indexPath.row)),
                    toggled: isToggled(at: (indexPath.section, indexPath.row)))
        toggle(at: (indexPath.section, indexPath.row))

        tableView.beginUpdates()
        tableView.endUpdates()
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let lastVisibleIndexPath = tableView.indexPathsForVisibleRows?.last {
            let defaults = UserDefaults.standard
            if indexPath == lastVisibleIndexPath &&
               !didScrollToCurrentLesson &&
               defaults.bool(forKey: "scrollToToday") {

                tableView.scrollToRow(
                    at: IndexPath(
                        row: 0,
                        section: TimeManager.shared.getCurrentWeekDay()),
                    at: .top, animated: true)
                didScrollToCurrentLesson = true
            }
        }
    }
}
