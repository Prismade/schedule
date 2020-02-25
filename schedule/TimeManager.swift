import Foundation


/**
 Методы для получения времени в том или ином виде и ключей API.
 */
protocol TimeManaging {
    /// Возвращает время в полночь понедельника.
    /// - parameter weekOffset: сдвиг (в количестве недель) относительно текущей недели.
    func getMonday(for weekOffset: Int) -> Date
    
    /**
     Создает ключ API для получения расписания.
     - parameter weekOffset: сдвиг (в количестве недель) относительно текущей недели.
     - returns: строковое представление ключа.
     Ключ представляет собой время в полночь понедельника с миллисекундами в формате Unix epoch.
     */
    func getApiTimeKey(for weekOffset: Int) -> String
    
    /// Возвращает дату начала и конца недели.
    /// - parameter weekOffset: сдвиг (в количестве недель) относительно текущей недели.
    func getWeekBoundaries(for weekOffset: Int) -> String
    
    /**
     Возвращает даты для каждого из дней недели
     - parameter weekOffset: сдвиг (в количестве недель) относительно текущей недели.
     - returns: даты для каждого дня недели
     */
    func getWeekDates(for weekOffset: Int) -> [Date]
    
    /// Возвращает номер текущего дня недели.
    func getCurrentWeekDay() -> Int

    /// Возвращает время начала и конца пары.
    /// - parameter lessonNumber: номер пары.
    func getTimeBoundaries(for lessonNumber: Int) -> String
    
    /** Возвращает время начала и конца пары как экземпляры класса Date
     - parameter lessonNumber: номер пары.
     - parameter day: номер дня.
     - parameter weekOffset: сдвиг (в количестве недель) относительно текущей недели.
     */
    func getTimeBoundariesAsDates(for lessonNumber: Int, on day: Int, weekOffset: Int) -> (Date, Date)
    
    /// Возвращает номер текущей пары.
    func getCurrentLessonNumber() -> Int
    
    /**
     Проверяет валиден ли кэш
     - parameter expirationTime: время когда кэш должен перестать быть валидным
     - returns: true, если кэш валиден, false - в противном случае
     */
    func validateCache(expirationTime: Date) -> Bool


}

extension TimeManaging {
    func getTimeBoundaries(for lessonNumber: Int) -> String {
        switch lessonNumber {
        case 1:
            return "8:30-10:00"
        case 2:
            return "10:10-11:40"
        case 3:
            return "12:00-13:30"
        case 4:
            return "13:40-15:10"
        case 5:
            return "15:20-16:50"
        case 6:
            return "17:00-18:30"
        case 7:
            return "18:40-20:10"
        case 8:
            return "20:15-21:45"
        default:
            return ""
        }
    }
}


final class TimeManager: TimeManaging {

    // MARK: - Public Properties

    static let shared = TimeManager()
    
    // MARK: - Private Properties

    private var calendar = Calendar(identifier: .iso8601)

    // MARK: - Initializers

    private init() {
        calendar.timeZone = TimeZone(abbreviation: "MSK")!
    }

    // MARK: - Public Methods

    func getMonday(for weekOffset: Int) -> Date {
        let date = Date()
        let offset: Int

        if calendar.dateComponents([.weekday], from: date).weekday! == 1 {
            offset = weekOffset + 1
        } else {
            offset = weekOffset
        }

        let components = calendar.dateComponents([.weekOfYear, .yearForWeekOfYear], from: date)
        let monday = calendar.date(from: components)!
        return calendar.date(byAdding: .weekOfYear, value: offset, to: monday)!
    }

    func getApiTimeKey(for weekOffset: Int) -> String {
        let monday = getMonday(for: weekOffset)
        return String(Int(monday.timeIntervalSince1970) * 1000)
    }

    func getWeekBoundaries(for weekOffset: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"

        let monday = getMonday(for: weekOffset)
        let sunday = calendar.date(byAdding: .day, value: 6, to: monday)!

        return "\(formatter.string(from: monday))-\(formatter.string(from: sunday))"
    }
    
    func getWeekDates(for weekOffset: Int) -> [Date] {
        var weekDates = [Date]()
        let monday = getMonday(for: weekOffset)
        
        for i in 1...6 {
            let nextDay = calendar.date(byAdding: .day, value: i, to: monday)!
            weekDates.append(nextDay)
        }
        
        return weekDates
    }

    func getCurrentWeekDay() -> Int {
        return calendar.dateComponents([.weekday], from: Date()).weekday! - 1
    }
    
    func getTimeBoundariesAsDates(for lessonNumber: Int, on day: Int, weekOffset: Int) -> (Date, Date) {
        let monday = getMonday(for: weekOffset)
        let dayDate = calendar.date(byAdding: .day, value: day - 1, to: monday)!
        
        let boundaries = getTimeBoundaries(for: lessonNumber)
        let separatedBoundaries = boundaries.split(separator: "-")
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        
        let start = formatter.date(from: String(separatedBoundaries[0]))!
        var components = calendar.dateComponents([.hour, .minute], from: start)
        let startDate = calendar.date(byAdding: components, to: dayDate)!
        
        let finish = formatter.date(from: String(separatedBoundaries[1]))!
        components = calendar.dateComponents([.hour, .minute], from: finish)
        let finishDate = calendar.date(byAdding: components, to: dayDate)!
        
        return (startDate, finishDate)
    }

    func getCurrentLessonNumber() -> Int {
        let lessonsStartTimeInMinutes =
            [10 * 60, 11 * 60 + 40, 13 * 60 + 30,
             15 * 60 + 10, 16 * 60 + 50, 18 * 60 + 30,
             20 * 60 + 10, 24 * 60]
        let components = calendar.dateComponents([.hour, .minute], from: Date())
        let timeInMinutes = components.hour! * 60 + components.minute!
        return lessonsStartTimeInMinutes.firstIndex { timeInMinutes <= $0 }!
    }
    
    func validateCache(expirationTime: Date) -> Bool {
        return expirationTime <= Date() ? false : true
    }


}
