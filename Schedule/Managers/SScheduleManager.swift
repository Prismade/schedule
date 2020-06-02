import Foundation
import Alamofire

final class SScheduleDay: Codable {
    let weekDay: SWeekDay
    let classes: [SClass]
    
    init(weekDay: SWeekDay, classes: [SClass]) {
        self.weekDay = weekDay
        self.classes = classes
    }
}

final class SScheduleData {
    
    enum UserKind {
        case student
        case teacher
    }
    
    // MARK: - Public properties
    
    // delegate closure
    var didFinishDataUpdate: ((Error?) -> Void)?
    
    var userKind: UserKind!
    var userId: Int?
    var schedule = [SScheduleDay]()
    var numberOfDays: Int { return schedule.count }
    var weekOffset: Int = 0 {
        didSet { updateData() }
    }
    
    // MARK: - Initialization
    
    init(for userKind: UserKind) {
        self.userKind = userKind
    }
    
    // MARK: - Public Methods
    
    func scheduleData(for day: SWeekDay) -> SScheduleDay? {
        guard day.rawValue <= schedule.count && day != .sunday else { return nil }
        return schedule[day.rawValue - 1]
    }
    
    func numberOfClasses(on day: SWeekDay) -> Int {
        guard let schedule = scheduleData(for: day) else { return 0 }
        return schedule.classes.count
    }
    
    func classData(number: Int, on day: SWeekDay) -> SClass? {
        guard let schedule = scheduleData(for: day) else { return nil }
        guard number <= schedule.classes.count && number >= 0 else { return nil }
        return schedule.classes[number]
    }
    
    func updateData(force: Bool = false) {
        guard let id = userId else { return }
        
        let needCaching: Bool = {
            switch userKind {
                case .student:
                    return SDefaults.cachingUserKind == .student || SDefaults.cachingUserKind == .both
                case .teacher:
                    return SDefaults.cachingUserKind == .teacher || SDefaults.cachingUserKind == .both
                default: return false
            }
        }()
        
        if SDefaults.isCachingEnabled && force == false && needCaching {
            if let cachedSchedule = SCacheManager.shared.retrieveSchedule(
                weekOffset: weekOffset,
                for: userKind == .student ? .student : .teacher) {
                schedule = cachedSchedule
                didFinishDataUpdate?(nil)
                return
            }
        }
        let completionHandler: (DataResponse<[SClass], AFError>) -> Void =
        { [unowned self, needCaching] response in
            switch response.result {
                case .success(let newSchedule): DispatchQueue.main.async {
                    self.schedule = (1...6).map { weekDay in
                        let classes = newSchedule.filter {
                            $0.weekDay == weekDay ? true : false
                        }.sorted()
                        return SScheduleDay(weekDay: SWeekDay(rawValue: weekDay)!, classes: classes)
                    }
                    
                    if SDefaults.isCachingEnabled && needCaching && self.weekOffset >= 0 {
                        do {
                            try SCacheManager.shared.cacheSchedule(
                                self.schedule,
                                weekOffset: self.weekOffset,
                                kind: self.userKind == .student ? .student : .teacher)
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    
                    self.didFinishDataUpdate?(nil)
                }
                
                case .failure(let error): DispatchQueue.main.async {
                    self.didFinishDataUpdate?(error)
                }
            }
        }
        
        switch userKind {
            case .student:
                SApiManager.shared.getStudentSchedule(
                    for: id,
                    on: weekOffset,
                    completion: completionHandler)
            case .teacher:
                SApiManager.shared.getTeacherSchedule(
                    for: id,
                    on: weekOffset,
                    completion: completionHandler)
            default: return
        }
    }
    
}

final class SScheduleManager {
    
    // MARK: - Static Properties
    
    static let shared = SScheduleManager()
    
    // MARK: - Public properties
    
    var studentSchedule = SScheduleData(for: .student)
    var teacherSchedule = SScheduleData(for: .teacher)
    
    // MARK: - Initialization
    
    private init() { }
    
}
