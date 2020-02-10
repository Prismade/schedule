import Foundation


class CacheItem: Codable {
    let data: [ScheduleDay]
    let expirationTime: Date
    
    init(data: [ScheduleDay], expirationTime: Date) {
        self.data = data
        self.expirationTime = expirationTime
    }
}
