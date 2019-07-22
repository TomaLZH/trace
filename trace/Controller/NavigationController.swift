//
//  NavigationController.swift
//  trace
//
//  Created by Justin Tey on 01/07/2019.
//  Copyright © 2019 NYP. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FirebaseDatabase
import Firebase



class NavigationController: UIViewController {
    var place: CLLocationCoordinate2D?
    var arraya : [String]?
    var country = ""
    var date = ""
    var venue: [String] = []
    var ref: DatabaseReference?
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 2000
    var previousLocation: CLLocation?
    let geoCoder = CLGeocoder()
    var directionsArray: [MKDirections] = []
    
    var currentPos: CLLocationCoordinate2D?
    
    @IBOutlet weak var SegmentSelected: UISegmentedControl!
    @IBAction func Segmentchanged(_ sender: Any) {
        switch SegmentSelected.selectedSegmentIndex{
        case 0: showNearbyAttractions(currentPos, "all")
        case 1: showNearbyAttractions(currentPos, "food")
        case 2: showNearbyAttractions(currentPos, "drinks")
        case 3: showNearbyAttractions(currentPos, "arts")
        case 4: showNearbyAttractions(currentPos, "shops")
        default: break
        }
    }
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var goButton: UIButton!


    
    
    
    @IBAction func weather(_ sender: Any) {
        if CLLocationManager.locationServicesEnabled(){
            switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways, .authorizedWhenInUse:
                print("Authorized.")
                let lat = locationManager.location?.coordinate.latitude
                let long = locationManager.location?.coordinate.longitude
                let location = CLLocation(latitude: lat!, longitude: long!)
                CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error)in
                    if error != nil {
                        return
                    } else if let country = placemarks?.first?.country,
                        let city = placemarks?.first?.locality {
                        print(country)
                        print(city)
                        
                        let weatherGetter = GetWeather()
                        weatherGetter.getWeather(city: city)
                        
                    }
                    
                })
                
            default: break
            }
        }
    }

    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentPos = locationManager.location?.coordinate
        
        showNearbyAttractions(currentPos, "all")
//        goButton.layer.cornerRadius = goButton.frame.size.height/2
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //IF user redirected from asking direction from the chat. This is trigger
        print(MapState.nearbyCategory)
        if MapState.nearbyCategory != nil {
            mapView.removeAnnotations(mapView.annotations)
            getDirections(currentPos, MapState.nearbyCategory)
        }
    }
    
    
    
    //ATTRACTIONS NEARBY
    func showNearbyAttractions(_ pos: CLLocationCoordinate2D?, _ section: String) {

        checkLocationServices()
        mapView.removeOverlays(mapView.overlays)
        //remove annotation to reset the map
        mapView.removeAnnotations(mapView.annotations)
        
        //convert Coordinate to String
        let lat = String(format:"%f", (pos!.latitude))
        let lng = String(format:"%f", (pos!.longitude))
        
        // put in the values to get the JSON reply
        guard var url = URL(string: "https://api.foursquare.com/v2/venues/explore?client_id=5PNCWIYXYGVUNIWYQYVXXMYXE50JG0FVLVOHG0HCCT0DNYGY&client_secret=4MZQUKPM4W3HOUX2WMKEPNWA4VHNNXOY4HWMTEPC0R2VDDLH&v=20190701&ll=\(lat),\(lng)&limit=20&section=\(section)") else { return }
        
        let session = URLSession.shared
        session.dataTask(with: url){(data,response,error) in
            if var response = response {
                
            }
            if var data = data{
                
                do{
                    
                    // Make the JSON readable and go through the array/dictionary to get
                    let output = try JSONSerialization.jsonObject(with: data, options:[]) as! [String:Any]
                    let venues = output["response"] as! NSDictionary
                    let venues2 = venues["groups"] as! NSArray
                    let venues3 = venues2.value(forKeyPath: "items.venue.name") as! NSArray
                    
                    //- name
                    let listname = venues3[0] as! NSArray
                    
                    //- latitude
                    let lata = venues2.value(forKeyPath: "items.venue.location.lat") as! NSArray
                    let lats = lata[0] as! NSArray
                    
                    //- longitude
                    let longa = venues2.value(forKeyPath: "items.venue.location.lng") as! NSArray
                    let longs = longa[0] as! NSArray
                
                    //Loop through to assign the coordinates
                    for i in 0..<listname.count{
                    
                        //Dispatch Queue to make the pins appear faster
                        DispatchQueue.global(qos: .background).sync{
                        
                        // Assign the annotation with the approiate value
                            var annotation = MKPointAnnotation()
                            annotation.title = listname[i] as! String
                            annotation.coordinate = CLLocationCoordinate2D(latitude: lats[i] as! Double, longitude: longs[i] as! Double)
                            print(annotation.coordinate)
                            
                            // Add the Annotation
                            DispatchQueue.main.async {
                                self.mapView.addAnnotation(annotation)
                            }
                        }
                    }
                    
                } catch{
                    print(error)
                }
                
            }
            }.resume()
    }
    
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            // Show alert letting the user know they have to turn this on.
            let alert = UIAlertController(title: "Turn on location services", message: "Go to General -> Settings -> Privacy", preferredStyle: UIAlertController.Style.alert)
            
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
            
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            startTackingUserLocation()
        case .denied:
            // Show alert instructing them how to turn on permissions
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // Show an alert letting them know what's up
            break
        case .authorizedAlways:
            break
        }
    }
    
    
    func startTackingUserLocation() {
        mapView.showsUserLocation = true
        centerViewOnUserLocation()
        locationManager.startUpdatingLocation()
        previousLocation = getCenterLocation(for: mapView)
    }
    
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    
    func getDirections(_ pos : CLLocationCoordinate2D?,_ nearbycat: String?) {
        
        
        
        //get the location
        checkLocationServices()
        
        //Convert Coordinate to String
        let lat = String(format:"%f", pos!.latitude)
        let lng = String(format:"%f", pos!.longitude)
        let cata = nearbycat as! String
        //replace white space of category to ,
        let cat = cata.replacingOccurrences(of: " ", with: ",")
        //Put in parameters to get approiate JSON reply
        guard let url = URL(string: "https://api.foursquare.com/v2/venues/explore?client_id=5PNCWIYXYGVUNIWYQYVXXMYXE50JG0FVLVOHG0HCCT0DNYGY&client_secret=4MZQUKPM4W3HOUX2WMKEPNWA4VHNNXOY4HWMTEPC0R2VDDLH&v=20190701&opennow=1&sortbydistance=1&ll=\(lat),\(lng)&limit=1&query=\(cat)") else { return }
        
        let session = URLSession.shared
        session.dataTask(with: url){(data,response,error) in
            if let response = response { }
            if let data = data {
                do {
                    // FIND LAT AND LONG FroM JSON
                    
                    let output = try JSONSerialization.jsonObject(with: data, options:[]) as! [String:Any]
                    let venues = output["response"] as! NSDictionary
                    let venues2 = venues["groups"] as! NSArray
                    let venues3 = venues2.value(forKeyPath: "items.venue.name") as! NSArray
                    let listname = venues3[0] as! NSArray
                    

                    
                    let lata = venues2.value(forKeyPath: "items.venue.location.lat") as! NSArray
                    let lats = lata[0] as! NSArray
                    let lati = lats[0] as! Double
 
                    
                    let longa = venues2.value(forKeyPath: "items.venue.location.lng") as! NSArray
                    let longs = longa[0] as! NSArray
                    let longi = longs[0] as! Double
                    
                    //ASSIGN JSON Coordinate TO PLACE
                    self.place = CLLocationCoordinate2D(latitude: lati, longitude: longi)
                    print(self.place)
                    
                    //GET DIRECTIONS TO  PLACE
                    let request = createDirectionsRequest(from: self.place!)
                    let directions = MKDirections(request: request)
                    resetMapView(withNew: directions)
                    
                    //add annotation to the target place
                    let annotation = MKPointAnnotation()
                    annotation.title = listname[0] as! String
                    annotation.coordinate = CLLocationCoordinate2D(latitude: self.place!.latitude, longitude: self.place!.longitude)
                    self.mapView.addAnnotation(annotation)
                    
                    //add the line
                    directions.calculate { [unowned self] (response, error) in
                        //Handle error if needed
                        guard let response = response else { return } //TODO: Show response not available in an alert
                        
                        for route in response.routes {
                            self.mapView.addOverlay(route.polyline)
                            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                        }
                    }
                    
                    
                    MapState.nearbyCategory = nil
                } catch{
                    print(error)
                }
                
            }
        }.resume()
    
    
        


    
    
    
    func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request {
        let destinationCoordinate       = getCenterLocation(for: mapView).coordinate//replace with corrdinates obtained from zh in an array
        let startingLocation            = MKPlacemark(coordinate: coordinate)
        let destination                 = MKPlacemark(coordinate: destinationCoordinate)
        
        let request                     = MKDirections.Request()
        request.source                  = MKMapItem(placemark: startingLocation)
        request.destination             = MKMapItem(placemark: destination)
        request.transportType           = .walking
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    
    func resetMapView(withNew directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
    }
    
    
    
}
}

extension NavigationController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}


//  Show center location on label
extension NavigationController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        
        guard let previousLocation = self.previousLocation else { return }
        
        guard center.distance(from: previousLocation) > 50 else { return }
        self.previousLocation = center
        
        geoCoder.cancelGeocode()
        
        geoCoder.reverseGeocodeLocation(center) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let _ = error {
                //Show alert informing the user
                return
            }
            
            guard let placemark = placemarks?.first else {
                //how alert informing the user
                return
            }
            
            let streetNumber = placemark.subThoroughfare ?? ""
            let streetName = placemark.thoroughfare ?? ""
            
          //  DispatchQueue.main.async {
           //     self.addressLabel.text = "\(streetNumber) \(streetName)"
            //}
        }
    }
 
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        
        return renderer
    }
    
    // This allows you to change how the annotations look
    // to the user. From markers to pins
    //
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) ->
        MKAnnotationView? {
            // The user's current location is also considered an annotation
            // on the map. We are not going to override how it looks
            // so let's just return nil.
            //
            if annotation is MKUserLocation
            { return nil
            }
            // This behaves like the Table View's dequeue re-usable cell.
            //
            var annotationView = mapView.dequeueReusableAnnotationView( withIdentifier: "pin")
            
            // If there aren't any reusable views to dequeue,
            // we will have to create a new one.
            //
            if annotationView == nil {
                var pinAnnotationView = MKPinAnnotationView()
                annotationView = pinAnnotationView
            }
            // Assign the annotation (the 2nd parameter)
            // to the pin so that iOS knows where to position
            // it in the map.
            //
            annotationView?.annotation = annotation
            // Setting this to true allows the callout bubble
            // to pop up when the user clicks on the pin
            //
            annotationView?.canShowCallout = true
            
            
            let rightIconView = UIButton(type: .infoLight)
            annotationView?.rightCalloutAccessoryView = rightIconView
            
            return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let annView = view.annotation
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailsVC = storyboard.instantiateViewController(withIdentifier: "details") as! detailscontroller
        
        detailsVC.latitude = annView?.coordinate.latitude
        detailsVC.longitude = annView?.coordinate.longitude
        
        self.navigationController?.pushViewController(detailsVC, animated: true)
    }

}

