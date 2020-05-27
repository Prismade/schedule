import UIKit
import SDStateTableView

class SStudentScheduleViewController: UIViewController {
    
    struct SelectedClass {
        let day: SWeekDay
        let number: Int
    }
    
    @IBOutlet weak var calendar: SCalendarView!
    @IBOutlet weak var schedule: SScheduleView!
    
    var lastSelectedClass: SelectedClass? = nil
    
    override func viewDidLoad() {
        
//        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.layoutIfNeeded()
        
        SScheduleManager.shared.studentSchedule.userId = SDefaults.studentId
        SScheduleManager.shared.studentSchedule.didFinishDataUpdate = { error in
            if let err = error {
                debugPrint(err.localizedDescription)
            } else {
                self.schedule.reloadData()
            }
        }
        
        calendar.weekDaysForPage = { index in
            let weekDates = STimeManager.shared.getDates(for: index)
            return weekDates
        }
        
        calendar.dayWasSelected = { calendar, indexPath in
            self.schedule.scrollToDay(indexPath.day)
        }
        
        calendar.weekWasChanged = { calendar, newWeekOffset in
            SScheduleManager.shared.studentSchedule.schedule.removeAll()
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
        schedule.tableViewDelegate = self
        schedule.prepareForUpdate()
        SScheduleManager.shared.studentSchedule.updateData()
    }
    
    override func viewDidLayoutSubviews() {
        let weekDay = STimeManager.shared.getCurrentWeekday()
        calendar.instantiateView(for: weekDay)
        schedule.instantiateView(for: weekDay)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ?? "" == "ClassDetailFromStudentSegue" {
            guard let lastSelectedClass = lastSelectedClass else { return }
            let classDetails = segue.destination as! SClassDetailsViewController
            classDetails.classData = SScheduleManager.shared.studentSchedule.classData(number: lastSelectedClass.number, at: lastSelectedClass.day)
            classDetails.userKind = .student
            
        }
    }
    
}

extension SStudentScheduleViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 || tableView.tag == 7 {
            return 0
        } else {
            let numberOfClasses = SScheduleManager.shared.studentSchedule.numberOfClasses(on: SWeekDay(rawValue: tableView.tag)!)
            return numberOfClasses
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: schedule.reuseIdentifier, for: indexPath) as! SScheduleTableViewCell
        let classData = SScheduleManager.shared.studentSchedule.classData(number: indexPath.row, at: SWeekDay(rawValue: tableView.tag)!)!
        cell.configure(with: classData, cellKind: .student)
        return cell
    }
    
}

extension SStudentScheduleViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        lastSelectedClass = SelectedClass(
            day: SWeekDay(rawValue: tableView.tag)!,
            number: indexPath.row)
        performSegue(withIdentifier: "ClassDetailFromStudentSegue", sender: self)
    }
    
}
