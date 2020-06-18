import Foundation

final class SScheduleDay: Codable {
    
    let weekDay: SWeekDay
    var classes: [SClass]
    
    init(weekDay: SWeekDay, classes: [SClass]) {
        self.weekDay = weekDay
        self.classes = classes
    }
    
}
