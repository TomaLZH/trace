import UIKit
import MapKit
import CoreLocation

class TaskMapController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    var lm: CLLocationManager?
    var task: Task?
    var coordinatesPassed: CLLocationCoordinate2D?

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
    
    @IBAction func onSetCurrentPress(_ sender: Any) {
        coordinatesPassed = mapView.centerCoordinate
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
