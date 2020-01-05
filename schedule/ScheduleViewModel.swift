import Foundation
import UIKit
import Alamofire


final class ScheduleViewModel: NSObject {

    final class Day {
        let title: String
        let lessons: [Lesson]

        init(weekDay: Int, lessons: [Lesson]) {
            self.lessons = lessons
            
            switch weekDay {
            case 1: title = "Понедельник"
            case 2: title = "Вторник"
            case 3: title = "Среда"
            case 4: title = "Четверг"
            case 5: title = "Пятница"
            case 6: title = "Суббота"
            default: title = ""
            }
        }
    }

    // MARK: - Public Properties

    var dataUpdateDidFinishSuccessfully: (() -> Void)?
    var dataUpdateDidFinishWithFailure: ((Error) -> Void)?

    // MARK: - Private Properties

    private var scheduleTable = [Day]()
    private var didScrollToCurrentLesson = false

    // MARK: - Public Methods

    func update(for group: Int, on weekOffset: Int) {
        ApiManager.shared.getStudentSchedule(for: group, on: weekOffset) { [unowned self] response in
            switch response.result {
            case .success(let result): DispatchQueue.main.async {
                self.requestSucceeded(with: result)
                guard let callback = self.dataUpdateDidFinishSuccessfully else { return }
                callback()
                }
            case .failure(let error): DispatchQueue.main.async {
                guard let callback = self.dataUpdateDidFinishWithFailure else { return }
                callback(error)
                }
            }
        }
    }

    func lesson(at position: (day: Int, number: Int)) -> Lesson? {
        let (day, number) = position
        if number >= scheduleTable[day].lessons.count {
            return nil
        } else {
            return scheduleTable[day].lessons[number]
        }
    }

    func schedule(for day: Int) -> Day {
        return scheduleTable[day]
    }

    // MARK: - Private Methods

    private func requestSucceeded(with response: [Lesson]) {
        scheduleTable = (1...6).map { weekDay in
            Day(weekDay: weekDay, lessons: response.filter { $0.weekDay == weekDay ? true : false }.sorted())
        }
    }


}

// MARK: - Extensions

extension ScheduleViewModel: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return scheduleTable.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return schedule(for: section).title
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let number = schedule(for: section).lessons.count
        if number == 0 {
            return 1 // for a cell, that tells there are no lessons
        } else {
            return number
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleTableCell", for: indexPath) as! ScheduleTableViewCell
        cell.configure(with: lesson(at: (indexPath.section, indexPath.row)))
        cell.selectionStyle = .none
        return cell
    }


}


extension ScheduleViewModel: UITableViewDelegate {
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
