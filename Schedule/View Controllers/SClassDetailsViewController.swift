import UIKit
import MapKit

class SClassDetailsViewController: UIViewController {
    
    enum UserKind {
        case student
        case teacher
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var subject: UILabel!
    @IBOutlet weak var specialInfo: UILabel!
    @IBOutlet weak var kind: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var user: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var map: MKMapView!
    
    // MARK: - Public Properties
    
    var userKind: UserKind?
    var classData: SClass?
    
    // MARK: - Private Properties
    
    private let tapRecognizer = UITapGestureRecognizer()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let data = classData, let userKind = userKind else { return }
        
        subject.text = data.subject
        if data.special != "" {
            specialInfo.text = "(\(data.special))"
        } else {
            specialInfo.text = ""
        }
        kind.text = "(\(data.kind))"
        if userKind == .teacher {
            user.text = data.groupTitleDesigned
        } else {
            user.text = data.fullEmployeeNameDesigned
            tapRecognizer.addTarget(self, action: #selector(handleTap(_:)))
            user.addGestureRecognizer(tapRecognizer)
        }
        
        location.text = data.locationDesigned
        guard let (begining, end) = STimeManager.shared.timetable[data.number] else { return }
        time.text = "\(begining)-\(end)"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard let data = classData else { return }
        
        SBuildingsManager.shared.setCoordinates(for: Int(data.building)!)
        { [unowned self] latitude, longtitude in
            guard let lat = latitude, let long = longtitude else { return }
            let annotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            annotation.coordinate = coordinate
            self.map.addAnnotation(annotation)
            self.map.setCenter(coordinate, animated: false)
            self.map.setRegion(MKCoordinateRegion(center: coordinate, latitudinalMeters: CLLocationDistance(floatLiteral: 300.0), longitudinalMeters: CLLocationDistance(floatLiteral: 300.0)), animated: false)
            
            self.map.alpha = 0.0
            self.map.isHidden = false
            UIView.animate(withDuration: 0.25, animations: {
                self.map.alpha = 1.0
            })
        }
    }
    
    // MARK: - Private Methods
    
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            performSegue(withIdentifier: "TeacherDetailsSegue", sender: self)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier ?? "" == "TeacherDetailsSegue" {
            guard let data = classData else { return }
            let destination = segue.destination as! UINavigationController
            let vc = destination.topViewController! as! STeacherDetailsViewController
            vc.employeeId = data.employeeId
        }
    }
    
}
