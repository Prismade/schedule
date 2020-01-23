import Foundation
import UIKit
import Alamofire


final class ScheduleViewModel: NSObject {

    final class Day: Codable {
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
    private var cacheFileName = "stud"

    // MARK: - Public Methods

    func update(for someone: Int, on weekOffset: Int) {
        if UserDefaults.standard.bool(forKey: "EnableCaching") {
            if let cachedSchedule: [Day] = CacheManager.shared.retrieve(weekOffset: weekOffset, from: cacheFileName) {
                scheduleTable = cachedSchedule
                guard let callback = dataUpdateDidFinishSuccessfully else { return }
                callback()
                return
            }
        }

        let copmletionHandler: (DataResponse<[Lesson], AFError>) -> Void = { [unowned self] response in
            switch response.result {
                case .success(let result): DispatchQueue.main.async {
                    self.requestSucceeded(with: result, for: weekOffset)
                    guard let callback = self.dataUpdateDidFinishSuccessfully else { return }
                    callback()
                }
                case .failure(let error): DispatchQueue.main.async {
                    guard let callback = self.dataUpdateDidFinishWithFailure else { return }
                    callback(error)
                }
            }
        }

        ApiManager.shared.getStudentSchedule(for: someone, on: weekOffset, completion: copmletionHandler)
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

    private func requestSucceeded(with response: [Lesson], for weekOffset: Int) {
        scheduleTable = (1...6).map { weekDay in
            Day(weekDay: weekDay, lessons: response.filter { $0.weekDay == weekDay ? true : false }.sorted())
        }

        if UserDefaults.standard.bool(forKey: "EnableCaching") {
            do {
                try CacheManager.shared.cache(scheduleTable, weekOffset: weekOffset, to: cacheFileName)
            } catch {
                debugPrint("unable to write file")
            }
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
