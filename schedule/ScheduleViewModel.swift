import Foundation
import UIKit
import Alamofire


final class ScheduleViewModel: NSObject {

    final class Day: Codable {
        let title: String
        let lessons: [Lesson]
        
        init(weekDay: Int, lessons: [Lesson], date: String) {
            self.lessons = lessons
            
            switch weekDay {
                case 1: title = "Понедельник (\(date))"
                case 2: title = "Вторник (\(date))"
                case 3: title = "Среда (\(date))"
                case 4: title = "Четверг (\(date))"
                case 5: title = "Пятница (\(date))"
                case 6: title = "Суббота (\(date))"
                default: title = ""
            }
        }
    }

    // MARK: - Public Properties

    var dataUpdateDidFinishSuccessfully: (() -> Void)?
    var dataUpdateDidFinishWithFailure: ((Error) -> Void)?

    // MARK: - Private Properties

    private var scheduleTable = [Day]()
    private var didPerformScrollOnStart = false
    private lazy var studentCacheFilePrefix = UserDefaults.standard.string(forKey: "StudentCacheFilePrefix")!
    private lazy var teacherCacheFilePrefix = UserDefaults.standard.string(forKey: "TeacherCacheFilePrefix")!

    // MARK: - Public Methods

    func update(on weekOffset: Int, force: Bool) {
        if !force {
            if UserDefaults.standard.bool(forKey: "EnableCaching") {
                let filePrefix: String!
                if UserDefaults.standard.bool(forKey: "Teacher") {
                    filePrefix = teacherCacheFilePrefix
                } else {
                    filePrefix = studentCacheFilePrefix
                }
                if let cachedSchedule: [Day] = CacheManager.shared.retrieve(weekOffset: weekOffset, from: filePrefix) {
                    scheduleTable = cachedSchedule
                    guard let callback = dataUpdateDidFinishSuccessfully else { return }
                    callback()
                    return
                }
            }
        }
        
        let completionHandler: (DataResponse<[Lesson], AFError>) -> Void = { [unowned self] response in
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
        
        let userId = UserDefaults.standard.integer(forKey: "UserId")
        if UserDefaults.standard.bool(forKey: "Teacher") {
            ApiManager.shared.getTeacherSchedule(for: userId, on: weekOffset, completion: completionHandler)
        } else {
            ApiManager.shared.getStudentSchedule(for: userId, on: weekOffset, completion: completionHandler)
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

    func forceCache(for weekOffset: Int) {
        do {
            try CacheManager.shared.cache(scheduleTable, weekOffset: weekOffset, to: studentCacheFilePrefix)
        } catch {
            debugPrint("unable to write file")
        }
    }

    // MARK: - Private Methods

    private func requestSucceeded(with response: [Lesson], for weekOffset: Int) {
        let dates = TimeManager.shared.getWeekDates(for: weekOffset)
        
        scheduleTable = (1...6).map { weekDay in
            Day(weekDay: weekDay, lessons: response.filter { $0.weekDay == weekDay ? true : false }.sorted(), date: dates[weekDay - 1])
        }

        if UserDefaults.standard.bool(forKey: "EnableCaching") {
            do {
                let filePrefix: String!
                if UserDefaults.standard.bool(forKey: "Teacher") {
                    filePrefix = teacherCacheFilePrefix
                } else {
                    filePrefix = studentCacheFilePrefix
                }
                try CacheManager.shared.cache(scheduleTable, weekOffset: weekOffset, to: filePrefix)
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
        let cellType: CellType!
        if UserDefaults.standard.bool(forKey: "Teacher") {
            cellType = .teacher
        } else {
            cellType = .student
        }
        cell.configure(with: lesson(at: (indexPath.section, indexPath.row)), cellType: cellType)
        cell.selectionStyle = .none
        return cell
    }


}


extension ScheduleViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let lastVisibleIndexPath = tableView.indexPathsForVisibleRows?.last {
            let defaults = UserDefaults.standard
            if indexPath == lastVisibleIndexPath &&
                !didPerformScrollOnStart &&
                defaults.bool(forKey: "ScrollOnStart") {
                tableView.scrollToRow(
                    at: IndexPath(
                        row: 0,
                        section: TimeManager.shared.getCurrentWeekDay()),
                    at: .top, animated: true)
                didPerformScrollOnStart = true
            }
        }
    }
}
