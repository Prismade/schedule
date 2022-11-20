import Foundation
import EventKit

struct SEMError: Error {
    enum ErrorKind {
        case accessDenied
        case accessRequestFailed
        case eventAdditionFailed
    }
    
    let kind: ErrorKind
    var localizedDescription: String
}


final class SExportManager {
    
    // MARK: - Static Properties
    
    static let shared = SExportManager()
    
    // MARK: - Public Properties
    
    lazy var eventStore = EKEventStore()
    var authStatus: EKAuthorizationStatus {
        return EKEventStore.authorizationStatus(for: EKEntityType.event)
    }
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Methods
    
    func requestPermission(completion: @escaping EKEventStoreRequestAccessCompletionHandler) {
        eventStore.requestAccess(to: EKEntityType.event, completion: completion)
    }
    
    func export(_ data: [SScheduleDay], weekOffset: Int, into calendar: EKCalendar) throws {
        do {
            switch authStatus {
            case .authorized:
                let _ = try data.enumerated().map { index, day in
                    try exportDay(day, number: index + 1, weekOffset: weekOffset, into: calendar)
                }
            case .denied, .restricted:
                throw SEMError(kind: .accessDenied, localizedDescription: "No access to calendar")
            default:
                return
            }
        } catch let error {
            throw error
        }
    }
    
    // MARK: - Private Methods
    
    private func exportDay(_ day: SScheduleDay, number: Int, weekOffset: Int, into calendar: EKCalendar) throws {
        let events = day.classes.enumerated().map { (index, lesson) in
            generateEvent(for: lesson, on: number, at: weekOffset, calendar: calendar)
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
            throw SEMError(kind: .eventAdditionFailed, localizedDescription: "Failed to add event to calendar")
        }
    }
    
    private func generateEvent(for classData: SClass, on day: Int, at weekOffset: Int, calendar: EKCalendar) -> EKEvent {
        let newEvent = EKEvent(eventStore: eventStore)
        newEvent.calendar = calendar
        newEvent.title = "\(classData.subject) (\(classData.kind))"
        newEvent.structuredLocation = EKStructuredLocation(title: classData.location)
        let (startDate, endDate) = STimeManager.shared.getTime(for: classData.number, on: day, weekOffset: weekOffset)
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
