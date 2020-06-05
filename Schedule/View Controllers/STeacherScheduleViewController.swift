import UIKit
import EventKit
import EventKitUI
import SDStateTableView
import AFCurvedArrowView

class STeacherScheduleViewController: UIViewController {
    
    struct SelectedClass {
        let day: SWeekDay
        let number: Int
    }
    
    @IBOutlet weak var calendar: SCalendarView!
    @IBOutlet weak var schedule: SScheduleView!
    @IBOutlet weak var placeholder: SSchedulePlaceholder!
    
    @IBAction func setupUserButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "SetupFromTeacherSegue", sender: self)
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
            let alert = UIAlertController(
                title: "\(NSLocalizedString("noPerm", comment: ""))",
                message: "\(NSLocalizedString("noPermMsg", comment: ""))",
                preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        default: return
        }
    }
    
    private var lastSelectedClass: SelectedClass? = nil
    private lazy var calendarSelectionViewController = UINavigationController()
    private let scheduleSource = SScheduleData(for: .teacher)
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(onModalDismiss(_:)),
            name: Notification.Name("TeacherSetupModalDismiss"), object: nil)
        
        scheduleSource.userId = SDefaults.teacherId
        scheduleSource.didFinishDataUpdate = { error in
            if let err = error {
                debugPrint(err.localizedDescription)
            } else {
                self.schedule.reloadData()
            }
        }
        
        calendar.weekDaysForWeekOffset = { weekOffset in
            let weekDates = STimeManager.shared.getDates(for: weekOffset)
            return weekDates
        }
        
        calendar.dayWasSelected = { calendar, indexPath in
            self.schedule.scrollToDay(indexPath.day)
        }
        
        calendar.weekWasChanged = { calendar, newWeekOffset in
            self.updateSchedule(newWeekOffset: newWeekOffset)
        }
        
        schedule.dayWasChanged = { schedule, day in
            self.calendar.selectedDay = day
        }
        
        schedule.weekWasChanged = { schedule, direction in
            self.scheduleSource.schedule.removeAll()
            switch direction {
                case .back:
                    self.calendar.weekOffset -= 1
                    self.calendar.selectedDay = .saturday
                case .forward:
                    self.calendar.weekOffset += 1
                    self.calendar.selectedDay = .monday
            }
            
            self.updateSchedule(newWeekOffset: self.calendar.weekOffset)
        }
        
        schedule.tableViewDataSource = self
        schedule.tableViewDelegate = self
        
        placeholder.message = NSLocalizedString("NeedTeacher", comment: "")
        if SDefaults.studentId != nil {
            placeholder.isHidden = true
            navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.layoutIfNeeded()
            updateSchedule()
        } else {
            placeholder.isHidden = false
        }
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
    
    @objc private func onModalDismiss(_ notification: Notification) {
        if let result = notification.userInfo {
            SDefaults.teacherId = (result as! [String : Int])["UserId"]
            scheduleSource.userId = SDefaults.teacherId
            placeholder.isHidden = true
            navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.layoutIfNeeded()
            updateSchedule()
        }
    }
    
    private func updateSchedule(newWeekOffset: Int? = nil) {
        for day in self.scheduleSource.schedule {
            day.classes.removeAll()
        }
        schedule.prepareForUpdate()
        
        if let weekOffset = newWeekOffset {
            self.scheduleSource.weekOffset = weekOffset
        } else {
            scheduleSource.updateData()
        }
    }
    
    private func chooseCalendar() {
        let ccvc = EKCalendarChooser(
            selectionStyle: .single,
            displayStyle: .writableCalendarsOnly,
            eventStore: SExportManager.shared.eventStore)
        ccvc.delegate = self
        ccvc.showsDoneButton = true
        ccvc.showsCancelButton = true

        calendarSelectionViewController.pushViewController(ccvc, animated: false)
        present(calendarSelectionViewController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ?? "" == "ClassDetailFromTeacherSegue" {
            guard let lastSelectedClass = lastSelectedClass else { return }
            let classDetails = segue.destination as! SClassDetailsViewController
            classDetails.classData = scheduleSource.classData(number: lastSelectedClass.number, on: lastSelectedClass.day)
            classDetails.userKind = .teacher
            
        } else if segue.identifier ?? "" == "SetupFromTeacherSegue" {
            let destination = segue.destination as! UINavigationController
            let vc = destination.topViewController! as! SDivisionSelectTableViewController
            vc.isTeacher = true
        }
    }
    
}

extension STeacherScheduleViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView.tag == 0 || tableView.tag == 7 {
            return 0
        } else {
            let numberOfClasses = scheduleSource.numberOfClasses(on: SWeekDay(rawValue: tableView.tag)!)
            return numberOfClasses
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: schedule.reuseIdentifier, for: indexPath) as! SScheduleTableViewCell
        let classData = scheduleSource.classData(number: indexPath.row, on: SWeekDay(rawValue: tableView.tag)!)!
        cell.configure(with: classData, cellKind: .teacher)
        return cell
    }
    
}

extension STeacherScheduleViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        lastSelectedClass = SelectedClass(
            day: SWeekDay(rawValue: tableView.tag)!,
            number: indexPath.row)
        performSegue(withIdentifier: "ClassDetailFromTeacherSegue", sender: self)
    }
    
}

extension STeacherScheduleViewController: EKCalendarChooserDelegate {
    
    func calendarChooserDidFinish(_ calendarChooser: EKCalendarChooser) {
        if let selectedCalendar = calendarChooser.selectedCalendars.first {
            do {
                let schedule = scheduleSource.schedule
                let weekOffset = scheduleSource.weekOffset
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
