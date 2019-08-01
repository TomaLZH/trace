import UIKit
import MapKit
import CoreLocation

class TaskMapController: UIViewController, CLLocationManagerDelegate {

    var lm: CLLocationManager?
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var setCurrentBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ////////////////////////////////////////////////
        // Setup LocationManager ///////////////////////
        lm = CLLocationManager()
        lm?.delegate = self
        lm?.desiredAccuracy = kCLLocationAccuracyBest
        lm?.distanceFilter = 0
        lm?.requestWhenInUseAuthorization()
        lm?.startUpdatingLocation()
        mapView.showsUserLocation = false
        ////////////////////////////////////////////////
    }
    
    // This function is called whenever the user's location is updated.
    // lm?.distanceFilter affects how much a location has to change before this is called
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc = locations.last!
        
        let region = MKCoordinateRegion(center: loc.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func onSetCurrentPress(_ sender: Any) {
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
