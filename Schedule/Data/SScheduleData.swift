import Foundation
import SwiftyJSON

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
    
    if force == false, let cachedSchedule = SCacheManager.shared.retrieveSchedule(weekOffset: weekOffset) {
      schedule = cachedSchedule
      didFinishDataUpdate?(nil)
      return
    }
    
    Task {
      do {
        let data = try await NetworkWorker().data(from: Oreluniver.schedule(group: id, weeksFromNow: weekOffset))
        let jsonData = try? JSON(data: data)
        guard let json = jsonData else { return }
        
        var newSchedule = [SClass]()
        for (key, _): (String, JSON) in json {
          if Int(key) != nil {
            newSchedule.append(
              SClass(
                cellId: json[key]["cell_id"].int,
                groupId: json[key]["idGruop"].intValue,
                subgroup: json[key]["NumberSubGruop"].intValue,
                subject: json[key]["TitleSubject"].stringValue,
                kind: json[key]["TypeLesson"].stringValue,
                number: json[key]["NumberLesson"].intValue,
                weekDay: json[key]["DayWeek"].intValue,
                building: json[key]["Korpus"].stringValue,
                room: json[key]["NumberRoom"].stringValue,
                special: json[key]["special"].stringValue,
                groupTitle: json[key]["title"].stringValue,
                employeeId: json[key]["employee_id"].int,
                patronymic: json[key]["SecondName"].stringValue,
                firstName: json[key]["Name"].stringValue,
                lastName: json[key]["Family"].stringValue))
          }
        }
        schedule = (1...6).map { weekDay in
          let classes = newSchedule.filter {
            $0.weekDay == weekDay ? true : false
          }.sorted()
          return SScheduleDay(weekDay: SWeekDay(rawValue: weekDay)!, classes: classes)
        }
        
        if weekOffset >= 0 {
          do {
            try SCacheManager.shared.cacheSchedule(
              schedule,
              weekOffset: weekOffset)
          } catch {
            print(error.localizedDescription)
          }
        }
        
        await MainActor.run {
          didFinishDataUpdate?(nil)
        }
      } catch {
        await MainActor.run {
          didFinishDataUpdate?(error)
        }
      }
    }
  }
  
}
