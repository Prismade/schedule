import UIKit
import MapKit


class ScheduleDetailsViewController: UIViewController {

    @IBOutlet weak var subject: UILabel!
    @IBOutlet weak var special: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var user: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var map: MKMapView!
    
    var day: Int!
    var lesson: Int!
    
    private var lessonData: Lesson!
    private let tapGestureRecognizer = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let data = ScheduleManager.shared.lesson(at: (day, lesson)) {
            lessonData = data

            subject.text = data.subject
            if data.special != "" {
                special.text = "(\(data.special))"
            } else {
                special.text = ""
            }
            type.text = "(\(data.type))"
            if UserDefaults.standard.bool(forKey: "Teacher") {
                user.text = data.groupTitleDesigned
            } else {
                user.text = data.fullEmployeeNameDesigned
                tapGestureRecognizer.addTarget(self, action: #selector(teacherLabelTaped(_:)))
                user.addGestureRecognizer(tapGestureRecognizer)
            }
            
            location.text = data.locationDesigned
            time.text = TimeManager.shared.getTimeBoundaries(for: data.number)
            
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        BuildingsManager.shared.setCoordinates(for: Int(lessonData.building)!) { [unowned self] latitude, longtitude in
            let annotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longtitude)
            annotation.coordinate = coordinate
            self.map.addAnnotation(annotation)
            self.map.setCenter(coordinate, animated: true)
            self.map.setRegion(MKCoordinateRegion(center: coordinate, latitudinalMeters: CLLocationDistance(floatLiteral: 300.0), longitudinalMeters: CLLocationDistance(floatLiteral: 300.0)), animated: true)
        }
    }
    
    @objc private func teacherLabelTaped(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .recognized {
            performSegue(withIdentifier: "ToTeacherProfile", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ?? "" == "ToTeacherProfile" {
            let destination = segue.destination as! UINavigationController
            let vc = destination.topViewController! as! TeacherProfileViewController
            vc.employeeId = lessonData.employeeId
        }
    }
}
