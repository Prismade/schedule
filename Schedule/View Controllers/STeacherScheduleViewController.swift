import UIKit
import SDStateTableView

class STeacherScheduleViewController: UIViewController {
    
    @IBOutlet weak var calendar: SCalendarView!
    @IBOutlet weak var schedule: SScheduleView!
    
    override func viewDidLoad() {
        SScheduleManager.shared.studentSchedule.userId = UserDefaults.standard.integer(forKey: "UserId")
        SScheduleManager.shared.studentSchedule.didFinishDataUpdate = { error in
            if let err = error {
                debugPrint(err.localizedDescription)
            } else {
                self.schedule.reloadData()
            }
        }
        
        calendar.weekDaysForWeekOffset = { index in
            let weekDates = STimeManager.shared.getDates(for: index)
            return weekDates
        }
        
        calendar.dayWasSelected = { calendar, indexPath in
            self.schedule.scrollToDay(indexPath.day)
        }
        
        calendar.weekWasChanged = { calendar, newWeekOffset in
            self.schedule.prepareForUpdate()
            SScheduleManager.shared.studentSchedule.weekOffset = newWeekOffset
        }
        
        schedule.dayWasChanged = { schedule, day in
            self.calendar.selectedDay = day
        }
        
        schedule.weekWasChanged = { schedule, direction in
            switch direction {
                case .back:
                    self.calendar.weekOffset -= 1
                    self.calendar.selectedDay = .saturday
                case .forward:
                    self.calendar.weekOffset += 1
                    self.calendar.selectedDay = .monday
            }
            
            schedule.prepareForUpdate()
            SScheduleManager.shared.studentSchedule.weekOffset = self.calendar.weekOffset
        }
        
        schedule.tableViewDataSource = self
        schedule.prepareForUpdate()
        SScheduleManager.shared.studentSchedule.updateData()
    }
    
    override func viewDidLayoutSubviews() {
        let weekDay = STimeManager.shared.getCurrentWeekday()
        if weekDay == .sunday {
            calendar.instantiateView(for: .monday)
            schedule.instantiateView(for: .monday)
        } else {
            calendar.instantiateView(for: weekDay)
            schedule.instantiateView(for: weekDay)
        }
        
    }
    
}

extension STeacherScheduleViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 || tableView.tag == 7 {
//            (tableView as! SDStateTableView).setState(.loading(message: "No schedule"))
            return 0
        } else {
            let numberOfClasses = SScheduleManager.shared.studentSchedule.numberOfClasses(on: SWeekDay(rawValue: tableView.tag)!)
//            (tableView as! SDStateTableView).setState(.dataAvailable)
            return numberOfClasses
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: schedule.reuseIdentifier, for: indexPath) as! SScheduleTableViewCell
        let classData = SScheduleManager.shared.studentSchedule.classData(number: indexPath.row, on: SWeekDay(rawValue: tableView.tag)!)!
        cell.configure(with: classData, cellKind: .student)
        return cell
    }
    
}
