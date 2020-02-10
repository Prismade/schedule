import Foundation
import EventKit

struct EMError: Error {
    enum ErrorKind {
        case accessDenied
        case accessRequestFailed
        case eventAdditionFailed
    }
    
    let kind: ErrorKind
    var localizedDescription: String
}


final class ExportManager {
    
    static let shared = ExportManager()
    
    lazy var eventStore = EKEventStore()
    
    private init() {}
    
    func authStatus() -> EKAuthorizationStatus {
        return EKEventStore.authorizationStatus(for: EKEntityType.event)
    }
    
    func requestPermission(completion: @escaping EKEventStoreRequestAccessCompletionHandler) {
        eventStore.requestAccess(to: EKEntityType.event, completion: completion)
    }
    
    func export(into calendar: EKCalendar) throws {
        let data = ScheduleManager.shared.fullSchedule()
        
        do {
            switch authStatus() {
            case .authorized:
                let _ = try data.enumerated().map { index, day in
                    try exportDay(day, number: index + 1, into: calendar)
                }
            case .denied, .restricted:
                throw EMError(kind: .accessDenied, localizedDescription: "No access to calendar")
            default:
                return
            }
        } catch let error {
            throw error
        }
    }
    
    private func exportDay(_ day: ScheduleDay, number: Int, into calendar: EKCalendar) throws {
        let events = day.lessons.enumerated().map { (index, lesson) in
            generateEvent(for: lesson, on: number, calendar: calendar)
        }
        let results: [Bool] = events.map {
            if !eventAlreadyExists(event: $0, in: calendar) {
                do {
                    try eventStore.save($0, span: .thisEvent)
                } catch {
                    return false
                }
            }
            
            return true
        }
        if !(results.reduce(true) { $0 && $1}) {
            throw EMError(kind: .eventAdditionFailed, localizedDescription: "Failed to add event to calendar")
        }
    }
    
    private func generateEvent(for lesson: Lesson, on day: Int, calendar: EKCalendar) -> EKEvent {
        let weekOffset = ScheduleManager.shared.getWeekOffset()
        let newEvent = EKEvent(eventStore: eventStore)
        newEvent.calendar = calendar
        newEvent.title = "\(lesson.subject) (\(lesson.type))"
        newEvent.structuredLocation = EKStructuredLocation(title: lesson.location)
        let (startDate, endDate) = TimeManager.shared.getTimeBoundariesAsDates(for: lesson.number, on: day, weekOffset: weekOffset)
        newEvent.startDate = startDate
        newEvent.endDate = endDate
        return newEvent
    }
    
    private func eventAlreadyExists(event eventToAdd: EKEvent, in calendar: EKCalendar) -> Bool {
        let predicate = eventStore.predicateForEvents(withStart: eventToAdd.startDate, end: eventToAdd.endDate, calendars: [calendar])
        let existingEvents = eventStore.events(matching: predicate)
        
        let res = existingEvents.contains { (event) -> Bool in
            return eventToAdd.title == event.title &&
                event.startDate == eventToAdd.startDate &&
                event.endDate == eventToAdd.endDate
        }
        return res
    }
    
    
}
