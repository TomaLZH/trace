import UIKit
import MapKit
import CoreLocation

class TaskMapController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var lm: CLLocationManager?
    var task: Task?
    var coordinatesPassed: CLLocationCoordinate2D?
    let geoCoder = CLGeocoder()
    var itineraryId: String?
    var coordinatesToEdit: CLLocationCoordinate2D?
    
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var setCurrentBtn: UIButton!
    @IBOutlet weak var searchBtn: UIButton!
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
        
        if coordinatesToEdit != nil {
            let region = MKCoordinateRegion.init(center: coordinatesToEdit!, latitudinalMeters: 1000, longitudinalMeters: 1000)
            self.mapView.setRegion(region, animated: true)
        } else {
            centerMap()
        }
    }
    
    func centerMap() {
        if itineraryId != nil {
            FirebaseDBController.loadItinerary(forItinerary: itineraryId!) {
                (currentIti) in
                
                self.geoCoder.geocodeAddressString(currentIti.country) {
                    (locations, error) in
                    
                    if let loc = locations?[0] {
                        let region = MKCoordinateRegion.init(center: loc.location!.coordinate, latitudinalMeters: 50000, longitudinalMeters: 50000)
                        self.mapView.setRegion(region, animated: true)
                    }
                    if let error = error {
                        print(error)
                    }
                }
            }
        }
        else if coordinatesToEdit != nil {
            let region = MKCoordinateRegion.init(center: coordinatesToEdit!, latitudinalMeters: 1000, longitudinalMeters: 1000)
            self.mapView.setRegion(region, animated: true)
        }
    }
    
    @IBAction func onSearchPress(_ sender: Any) {
        geoCoder.geocodeAddressString(searchField.text!) {
            (locations, error) in
            
            if let loc = locations?[0] {
                let region = MKCoordinateRegion.init(center: loc.location!.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                self.mapView.setRegion(region, animated: true)
            }
            if let error = error {
                print(error)
                let alert = UIAlertController(title: "Error", message: "This location cannot be found.", preferredStyle: .alert)
                
                alert.addAction(
                    UIAlertAction(title: "Okay",
                                  style: .default,
                                  handler: nil
                ))
                self.present(alert, animated: true, completion: nil)
                return
            }
        }
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
