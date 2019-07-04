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

class NavigationController: UIViewController {
    var arraya : [String]?

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var goButton: UIButton!
    
    @IBAction func goButtonTapped(_ sender: Any) {
        getDirections()
    }
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 5000
    var previousLocation: CLLocation?
    
    let geoCoder = CLGeocoder()
    var directionsArray: [MKDirections] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //ATTRACTIONS NEARBY
        guard let url = URL(string: "https://api.foursquare.com/v2/venues/explore?ll=40.7,-74&client_id=5PNCWIYXYGVUNIWYQYVXXMYXE50JG0FVLVOHG0HCCT0DNYGY&client_secret=4MZQUKPM4W3HOUX2WMKEPNWA4VHNNXOY4HWMTEPC0R2VDDLH&v=20190701&near=Bedok&limit=10") else{ return }
        
        
        
        let session = URLSession.shared
        session.dataTask(with: url){(data,response,error) in
            if let response = response{
                
            }
            if let data = data{
                
                do{
                    
                    
                    let output = try JSONSerialization.jsonObject(with: data, options:[]) as! [String:Any]
                    let venues = output["response"] as! NSDictionary
                    let venues2 = venues["groups"] as! NSArray
                    var venues3 = venues2.value(forKeyPath: "items.venue.name") as! NSArray
                    var list = venues3[0] as! NSArray
                    
                    for i in 0..<list.count{
                        print(list[i])
                    }
                    
                    var lats = venues2.value(forKeyPath: "items.venue.location.lat") as! NSArray
                    print(lats)
                    
                    var longs = venues2.value(forKeyPath: "items.venue.location.lng") as! NSArray
                    print(longs)
                    
                    
                    
                    
                    // print(attraction)
                    DispatchQueue.main.async {
                        
                        
                        //    self.resultattrac.text = "\(attraction)"
                    }
                } catch{
                    print(error)
                }
                
            }
            }.resume()
        
        
        
        
        
        
        goButton.layer.cornerRadius = goButton.frame.size.height/2
        checkLocationServices()
        
        
        var annotation = MKPointAnnotation()
        annotation.title = "Yio Chu Kang Station"
        annotation.coordinate =
            CLLocationCoordinate2D(latitude: 1.3817, longitude: 103.8449)
        mapView.addAnnotation(annotation)
        
        annotation = MKPointAnnotation()
        annotation.title = "Ang Mo Kio Station"
        annotation.coordinate = CLLocationCoordinate2D(latitude: 1.3700, longitude: 103.8496)
        mapView.addAnnotation(annotation)
        

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
    
    
    func getDirections() {
        guard let location = locationManager.location?.coordinate else {
            //Inform user we don't have their current location
            let alert = UIAlertController(title: "Sorry", message: "We don't have your current location", preferredStyle: UIAlertController.Style.alert)
            
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil))
            
            
            self.present(alert, animated: true, completion: nil)

            return
        }
        
        let request = createDirectionsRequest(from: location)
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions)
        
        directions.calculate { [unowned self] (response, error) in
            //Handle error if needed
            guard let response = response else { return } //TODO: Show response not available in an alert
            
            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    
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


extension NavigationController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}


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
            
            DispatchQueue.main.async {
                self.addressLabel.text = "\(streetNumber) \(streetName)"
            }
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
    


}
