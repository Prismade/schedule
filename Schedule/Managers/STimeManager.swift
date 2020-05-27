import Foundation

enum SWeekDay: Int, Codable {
    case monday = 1
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
}

final class STimeManager {
    
    // MARK: - Static Properties
    
    static let shared = STimeManager()
    
    // MARK: - Public Properties
    
    let timetable = [
        1: ("08:30", "10:00"),
        2: ("10:10", "11:40"),
        3: ("12:00", "13:30"),
        4: ("13:40", "15:10"),
        5: ("15:20", "16:50"),
        6: ("17:00", "18:30"),
        7: ("18:40", "20:10"),
        8: ("20:15", "21:45")]
    
    // MARK: - Private Properties
    
    private var calendar = Calendar(identifier: .iso8601)
    
    // MARK: - Initializers
    
    private init() { calendar.timeZone = TimeZone(abbreviation: "MSK")! }
    
    // MARK: - Public Methods
    
    func getMonday(for weekOffset: Int) -> Date {
        let date = getCurrentDate()
        let weekday = getCurrentWeekday()
        let offset = weekday == .sunday ? weekOffset + 1 : weekOffset
        let components = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: date)
        let monday = calendar.date(from: components)!
        return calendar.date(byAdding: .weekOfYear, value: offset, to: monday)!
    }
    
    func getCurrentDate() -> Date {
        return Date()
    }
    
    func getDates(for weekOffset: Int) -> [Date] {
        var weekDates = [Date]()
        var monday = getMonday(for: weekOffset)
        
        // without this formatter will return tomorrow date
        monday = calendar.date(byAdding: .hour, value: -1, to: monday)!
        
        for i in 1...6 {
            let nextDay = calendar.date(byAdding: .day, value: i, to: monday)!
            weekDates.append(nextDay)
        }
        
        return weekDates
    }
    
    func getCurrentWeekday() -> SWeekDay {
        let weekDay = calendar.dateComponents([.weekday], from: getCurrentDate()).weekday!
        if weekDay == 1 {
            return .sunday
        } else {
            return SWeekDay(rawValue: weekDay - 1)!
        }
    }
    
    func getNextWeekDay() -> Date {
        let today = getCurrentDate()
        var tomorrow = calendar.date(bySetting: .hour, value: 0, of: today)!
        tomorrow = calendar.date(bySetting: .minute, value: 0, of: tomorrow)!
        tomorrow = calendar.date(bySetting: .second, value: 0, of: tomorrow)!
        return tomorrow
    }
    
    func getApiKey(for weekOffset: Int) -> String {
        let monday = getMonday(for: weekOffset)
        return String(Int(monday.timeIntervalSince1970) * 1000)
    }
    
    func getTime(for classNumber: Int, on day: Int, weekOffset: Int) -> (Date, Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        let boundaries = timetable[classNumber]!
        
        let monday = getMonday(for: weekOffset)
        let dayDate = calendar.date(byAdding: .day, value: day - 1, to: monday)!
        
        let start = formatter.date(from: boundaries.0)!
        var components = calendar.dateComponents([.hour, .minute], from: start)
        let startDate = calendar.date(byAdding: components, to: dayDate)!
        
        let finish = formatter.date(from: boundaries.1)!
        components = calendar.dateComponents([.hour, .minute], from: finish)
        let finishDate = calendar.date(byAdding: components, to: dayDate)!
        
        return (startDate, finishDate)
    }
    
    func validateCache(expirationDate: Date) -> Bool {
        return expirationDate <= getCurrentDate() ? false : true
    }
    
}
