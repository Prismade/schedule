import UIKit
import EventKit
import EventKitUI
import SDStateTableView

class SStudentScheduleViewController: UIViewController {
    
    struct SelectedClass {
        let day: SWeekDay
        let number: Int
    }
    
    @IBOutlet weak var calendar: SCalendarView!
    @IBOutlet weak var schedule: SScheduleView!
    
    @IBAction func setupUserButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "SetupFromStudentSegue", sender: self)
    }
    
    @IBAction func calendarExportButtonTapped(_ sender: UIBarButtonItem) {
        switch SExportManager.shared.authStatus {
        case .notDetermined:
            SExportManager.shared.requestPermission { [unowned self] authorized, error in
                if authorized {
                    DispatchQueue.main.async {
                        self.chooseCalendar()
                    }
                }
            }
        case .authorized:
            chooseCalendar()
        case .denied:
            let alert = UIAlertController(title: "\(NSLocalizedString("noPerm", comment: ""))", message: "\(NSLocalizedString("noPermMsg", comment: ""))", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        default: return
        }
    }
    
    var lastSelectedClass: SelectedClass? = nil
    
    private lazy var calendarSelectionViewController = UINavigationController()
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onModalDismiss(_:)), name: Notification.Name("UserSetupModalDismiss"), object: nil)
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
        
        if SDefaults.studentId != nil {
            schedule.prepareForUpdate()
            SScheduleManager.shared.studentSchedule.updateData()
        } else {
            // TODO: Show message about need of choosing group
        }
    }
    
    override func viewDidLayoutSubviews() {
        let weekDay = STimeManager.shared.getCurrentWeekday()
        calendar.instantiateView(for: weekDay)
        schedule.instantiateView(for: weekDay)
    }
    
    @objc private func onModalDismiss(_ notification: Notification) {
        if let result = notification.userInfo {
            SDefaults.studentId = (result as! [String : Int])["UserId"]
            schedule.prepareForUpdate()
            SScheduleManager.shared.studentSchedule.userId = SDefaults.studentId
            SScheduleManager.shared.studentSchedule.updateData()
            // TODO: Hide message about need of choosing group
        }
    }
    
    private func chooseCalendar() {
        let ccvc = EKCalendarChooser(selectionStyle: .single, displayStyle: .writableCalendarsOnly, eventStore: SExportManager.shared.eventStore)
        ccvc.delegate = self
        ccvc.showsDoneButton = true
        ccvc.showsCancelButton = true

        calendarSelectionViewController.pushViewController(ccvc, animated: false)
        present(calendarSelectionViewController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ?? "" == "ClassDetailFromStudentSegue" {
            guard let lastSelectedClass = lastSelectedClass else { return }
            let classDetails = segue.destination as! SClassDetailsViewController
            classDetails.classData = SScheduleManager.shared.studentSchedule.classData(number: lastSelectedClass.number, at: lastSelectedClass.day)
            classDetails.userKind = .student
            
        } else if segue.identifier ?? "" == "SetupFromStudentSegue" {
            let destination = segue.destination as! UINavigationController
            let vc = destination.topViewController! as! SDivisionSelectTableViewController
            vc.isTeacher = false
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

extension SStudentScheduleViewController: EKCalendarChooserDelegate {
    
    func calendarChooserDidFinish(_ calendarChooser: EKCalendarChooser) {
        if let selectedCalendar = calendarChooser.selectedCalendars.first {
            do {
                let schedule = SScheduleManager.shared.studentSchedule.schedule
                let weekOffset = SScheduleManager.shared.studentSchedule.weekOffset
                try SExportManager.shared.export(schedule, weekOffset: weekOffset, into: selectedCalendar)
            } catch let error {
                print(error.localizedDescription)
            }
        }
        calendarSelectionViewController.dismiss(animated: true)
        
    }
    
    func calendarChooserDidCancel(_ calendarChooser: EKCalendarChooser) {
        calendarSelectionViewController.dismiss(animated: true)
    }
    
}
