import Foundation

class SCacheItem: Codable {
    
    let data: [SScheduleDay]
    let expirationDate: Date
    
    init(data: [SScheduleDay], expires expirationDate: Date) {
        self.data = data
        self.expirationDate = expirationDate
    }
    
}
