import UIKit
import CoreLocation
import MapKit

class FreeMapController: UIViewController, CLLocationManagerDelegate {
    
    var lm: CLLocationManager?
    @IBOutlet weak var mapView: MKMapView!
    
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
        ////////////////////////////////////////////////
        
        mapView.showsUserLocation = true
        
        // Call functions
        
        // showNearbyAttractions()
        // CAUSES ERRORS!!!!!
    }
    
    // This function is called whenever the user's location is updated.
    // lm?.distanceFilter affects how much a location has to change before this is called
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let loc = locations.last!
        
        let region = MKCoordinateRegion(center: loc.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }
    
    // Added by Zheng Han
    // To show nearby places as annotations
    func showNearbyAttractions() {
        //ATTRACTIONS NEARBY
        //String(format:"%f", a)
        mapView.removeAnnotations(mapView.annotations)
        
        guard let url = URL(string: "https://api.foursquare.com/v2/venues/explore?client_id=5PNCWIYXYGVUNIWYQYVXXMYXE50JG0FVLVOHG0HCCT0DNYGY&client_secret=4MZQUKPM4W3HOUX2WMKEPNWA4VHNNXOY4HWMTEPC0R2VDDLH&v=20190701&ll=0,0&limit=10&section=all") else { return }
        
        let session = URLSession.shared
        session.dataTask(with: url){(data,response,error) in
            if let response = response {
                
            }
            if let data = data{
                
                do{
                    
                    
                    let output = try JSONSerialization.jsonObject(with: data, options:[]) as! [String:Any]
                    let venues = output["response"] as! NSDictionary
                    print(venues)
                    let venues2 = venues["groups"] as! NSArray
                    let venues3 = venues2.value(forKeyPath: "items.venue.name") as! NSArray
                    let list = venues3[0] as! NSArray
                    
                    for i in 0..<list.count{
                        print(list[i])
                    }
                    
                    let lata = venues2.value(forKeyPath: "items.venue.location.lat") as! NSArray
                    let lats = lata[0] as! NSArray
                    print(lats)
                    
                    let longa = venues2.value(forKeyPath: "items.venue.location.lng") as! NSArray
                    let longs = longa[0] as! NSArray
                    
                    print(longs)
                    
                    for i in 0..<list.count{
                        var annotation = MKPointAnnotation()
                        annotation.title = list[i] as! String
                        annotation.coordinate = CLLocationCoordinate2D(latitude: lats[i] as! Double, longitude: longs[i] as! Double)
                        self.mapView.addAnnotation(annotation)
                    }
                    
                    
                } catch{
                    print(error)
                }
                
            }
        }.resume()
    }
}
