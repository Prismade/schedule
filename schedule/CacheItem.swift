import Foundation


class CacheItem: Codable {
    let data: [ScheduleViewModel.Day]
    let expirationTime: Date
    
    init(data: [ScheduleViewModel.Day], expirationTime: Date) {
        self.data = data
        self.expirationTime = expirationTime
    }
}
