import Foundation
import Alamofire


final class ScheduleDay: Codable {
    var title: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE (dd.MM.yy)"
        return formatter.string(from: date)
    }
    let lessons: [Lesson]
    let date: Date
    
    init(weekDay: Int, lessons: [Lesson], date: Date) {
        self.date = date
        self.lessons = lessons
    }
}

final class ScheduleManager {
    
    static let shared = ScheduleManager()
    private init() {}

    // MARK: - Private Properties
    
    private var weekOffset = 0;
    private var scheduleTable = [ScheduleDay]()
    private lazy var studentCacheFilePrefix = UserDefaults.standard.string(forKey: "StudentCacheFilePrefix")!
    private lazy var teacherCacheFilePrefix = UserDefaults.standard.string(forKey: "TeacherCacheFilePrefix")!

    // MARK: - Public Methods

    func update(force: Bool, completion: @escaping (Error?) -> Void) {
        if !force {
            if UserDefaults.standard.bool(forKey: "EnableCaching") {
                let filePrefix: String!
                if UserDefaults.standard.bool(forKey: "Teacher") {
                    filePrefix = teacherCacheFilePrefix
                } else {
                    filePrefix = studentCacheFilePrefix
                }
                if let cachedSchedule: [ScheduleDay] = CacheManager.shared.retrieveSchedule(weekOffset: weekOffset, from: filePrefix) {
                    scheduleTable = cachedSchedule
                    completion(nil)
                    return
                }
            }
        }
        
        let completionHandler: (DataResponse<[Lesson], AFError>) -> Void = { [unowned self] response in
            switch response.result {
                case .success(let result): DispatchQueue.main.async {
                    self.requestSucceeded(with: result, for: self.weekOffset)
                    completion(nil)
                }
                case .failure(let error): DispatchQueue.main.async {
                    completion(error)
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
    
    func setWeekOffset(_ new: Int, completion: @escaping (Error?) -> Void) {
        weekOffset = new
        update(force: false, completion: completion)
    }
    
    func getWeekOffset() -> Int {
        return weekOffset
    }
    
    func daysCount() -> Int {
        return scheduleTable.count
    }
    
    func lessonsCount(for day: Int) -> Int {
        return scheduleTable[day].lessons.count
    }
    
    func fullSchedule() -> [ScheduleDay] {
        return scheduleTable
    }

    func lesson(at position: (day: Int, number: Int)) -> Lesson? {
        let (day, number) = position
        if number >= scheduleTable[day].lessons.count {
            return nil
        } else {
            return scheduleTable[day].lessons[number]
        }
    }
    
    func title(for day: Int) -> String {
        return scheduleTable[day].title
    }

    func schedule(for day: Int) -> ScheduleDay {
        return scheduleTable[day]
    }

    func forceCache(for weekOffset: Int) {
        do {
            try CacheManager.shared.cacheSchedule(scheduleTable, weekOffset: weekOffset, to: studentCacheFilePrefix)
        } catch {
            debugPrint("Unable to write a file")
        }
    }

    // MARK: - Private Methods

    private func requestSucceeded(with response: [Lesson], for weekOffset: Int) {
        let dates = TimeManager.shared.getWeekDates(for: weekOffset)
        
        scheduleTable = (1...6).map { weekDay in
            let lessons = response.filter {
                $0.weekDay == weekDay ? true : false
            }.sorted()
            let date = dates[weekDay - 1]
            
            return ScheduleDay(weekDay: weekDay, lessons: lessons, date: date)
        }

        if UserDefaults.standard.bool(forKey: "EnableCaching") {
            do {
                let filePrefix: String!
                if UserDefaults.standard.bool(forKey: "Teacher") {
                    filePrefix = teacherCacheFilePrefix
                } else {
                    filePrefix = studentCacheFilePrefix
                }
                try CacheManager.shared.cacheSchedule(scheduleTable, weekOffset: weekOffset, to: filePrefix)
            } catch {
                debugPrint("Unable to write a file")
            }
        }
    }
}
