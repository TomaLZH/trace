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
        currentPos = locationManager.location?.coordinate
        
        if MapState.nearbyCategory != nil {
            getDirections(currentPos, MapState.nearbyCategory)
        }
        if MapState.placesID != nil {
            directionID(MapState.placesID!)
        }
        
        if MapState.searchplace != nil{
            searchplace(MapState.searchplace!)
        }
        print(MapState.region, MapState.venuetype, MapState.price, MapState.open,currentPos)
        
        
        if MapState.price != nil || MapState.open != nil || MapState.venuetype != nil{
            if MapState.region == nil {
                MapState.region = ""
            }
            search(MapState.region!,MapState.venuetype!,MapState.price!,MapState.open!,currentPos!)
        }
    }
    
    func search(_ region:String,_ venuetype:String,_ price:String,_ open:String,_ pos : CLLocationCoordinate2D){
        self.mapView.removeOverlays(self.mapView.overlays)
        //remove annotation to reset the map
        self.mapView.removeAnnotations(self.mapView.annotations)
        var placement = "near=\(region)"
        var openstatus = ""
        var pricea = ""
        print(region)
        let venuetypes = venuetype.replacingOccurrences(of: " ", with: ",")
        print(open)
        print(price)
        print(venuetype)
        let lat = String(format:"%f", (pos.latitude ?? 1.3801))
        let lng = String(format:"%f", (pos.longitude ?? 103.849))
        
        if open == "true" {
            openstatus = "1"
        }
        
        if price == "cheapest" {
            pricea = "1"
        }
        else if price == "cheap" {
            pricea = "1,2"
        }
        else if price == "expensive" {
            pricea = "3,4"
        }
        
        if region == "" {
            self.place = CLLocationCoordinate2D(latitude: pos.latitude, longitude: pos.latitude)
            placement = "ll=\(pos.latitude),\(pos.longitude)"
        }
        print(pricea)
        print(placement)
        guard var url = URL(string:"https://api.foursquare.com/v2/venues/explore?client_id=RSIQCDUUO1CU1NCAWP4J4FXUT150YB3ZERKYIUCEYV3DYMNF&client_secret=NS5FX4EMMRHA3RPEWWOEZLIQ4T2B20WFNAF310GRRQNM3N5U&v=20190701&\(placement)&query=\(venuetypes)&open=\(openstatus)&price=\(pricea)") else {return}
        
        let session = URLSession.shared
        session.dataTask(with: url){(data,response,error) in
            if var response = response{}
            if var data = data{
                do{
                    let output = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                    let venues = output["response"] as! NSDictionary
                    let venues2 = venues["groups"] as! NSArray
                    let venues3 = venues2[0] as! NSDictionary
                    let venues4 = venues3["items"] as! NSArray
                    
                    for i in 0..<venues4.count {
                        DispatchQueue.global(qos: .background).sync {
                            var annotation = MKPointAnnotation()
                            let venues5 = venues4[i] as! NSDictionary
                            let venues6 = venues5["venue"] as! NSDictionary
                            let name = venues6["name"] as! String
                            
                            let venues7 = venues6["location"] as! NSDictionary
                            let lat = venues7["lat"] as! Double
                            let long = venues7["lng"] as! Double
                            
                            annotation.title = name
                            annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                            
                            let center = annotation.coordinate
                            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15))
                            self.mapView.setRegion(region, animated: true)
                            DispatchQueue.main.async{
                                self.mapView.addAnnotation(annotation)
                            }
                        }
                    }
                    
                    
                    
                    
                    
                    MapState.region = nil
                    MapState.venuetype = nil
                    MapState.open = nil
                    MapState.price = nil
                }catch{
                    print(error)
                }
            }
            }.resume()
        
    }
    
    
    
    
    //search place
    func searchplace(_ place : String){
        
        self.mapView.removeOverlays(self.mapView.overlays)
        //remove annotation to reset the map
        self.mapView.removeAnnotations(self.mapView.annotations)
        print("search place")
        let placess = place as! String
        let places = placess.replacingOccurrences(of: " ", with: ",")
        guard var url = URL(string: "https://api.foursquare.com/v2/venues/search?client_id=RSIQCDUUO1CU1NCAWP4J4FXUT150YB3ZERKYIUCEYV3DYMNF&client_secret=NS5FX4EMMRHA3RPEWWOEZLIQ4T2B20WFNAF310GRRQNM3N5U&ll=44.3,37.2&v=20190701&intent=global&limit=20&query=\(places)"  )else{return}
        
        let session = URLSession.shared
        session.dataTask(with: url){(data,response,error) in
            if var response = response {
            }
            if var data = data{
                do{
                    print("bfkjasmdklasmlk")
                    
                    
                    let output = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                    let venues = output["response"] as! NSDictionary
                    let venues2 = venues["venues"] as! NSArray
                    let venues3 = venues2[0] as! NSDictionary
                    let nameplace = venues3["name"] as! String
                    let venues4 = venues3["location"] as! NSDictionary
                    let lat = venues4["lat"] as! Double
                    let long = venues4["lng"] as! Double
                    
                    
                    DispatchQueue.global(qos: .background).sync{
                        let annotation = MKPointAnnotation()
                        annotation.title = nameplace
                        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                        let center = CLLocationCoordinate2D(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
                        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                        self.mapView.setRegion(region, animated: true)
                        MapState.searchplace = nil
                        DispatchQueue.main.sync {
                            
                            
                            self.mapView.addAnnotation(annotation)
                        }
                    }
                    
                    
                } catch{
                    print(error)
                }
            }
            }.resume()
    }
    
    //get details
    
    func directionID (_ placesid : String){
        self.mapView.removeOverlays(self.mapView.overlays)
        //remove annotation to reset the map
        self.mapView.removeAnnotations(self.mapView.annotations)
        var placeid = placesid as! String
        
        guard var url = URL(string: "https://api.foursquare.com/v2/venues/\(placeid)?client_id=RSIQCDUUO1CU1NCAWP4J4FXUT150YB3ZERKYIUCEYV3DYMNF&client_secret=NS5FX4EMMRHA3RPEWWOEZLIQ4T2B20WFNAF310GRRQNM3N5U&v=20190701") else {return}
        let session = URLSession.shared
        session.dataTask(with: url){(data,response,error) in
            if var response = response {
                
            }
            if var data = data{
                do{
                    let output = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                    let venues = output["response"] as! NSDictionary
                    let venues2 = venues["venue"] as! NSDictionary
                    let venues3 = venues2["location"] as! NSDictionary
                    let lat = venues3["lat"] as! Double
                    let long = venues3["lng"] as! Double
                    print(lat,long)
                    let place = venues2["name"] as! String
                    print(place)
                    self.place = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    print(self.place)
                    let request = createDirectionsRequest(from:self.place!)
                    let directions = MKDirections(request: request)
                    resetMapView(withNew: directions)
                    
                    let annotation = MKPointAnnotation()
                    annotation.title = place
                    annotation.coordinate = CLLocationCoordinate2D(latitude: self.place!.latitude, longitude: self.place!.longitude)
                    self.mapView.addAnnotation(annotation)
                    
                    directions.calculate{ [unowned self] (response, error) in
                        guard let response = response else {return}
                        
                        for route in response.routes {
                            self.mapView.addOverlay(route.polyline)
                            self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                        }
                    }
                    
                    MapState.placesID = nil
                    
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
    
    //ATTRACTIONS NEARBY
    func showNearbyAttractions(_ pos: CLLocationCoordinate2D?, _ section: String) {
        
        checkLocationServices()
        self.mapView.removeOverlays(self.mapView.overlays)
        //remove annotation to reset the map
        self.mapView.removeAnnotations(self.mapView.annotations)
        
        //convert Coordinate to String
        let lat = String(format:"%f", (pos?.latitude ?? 1.3801))
        let lng = String(format:"%f", (pos?.longitude ?? 103.849))
        
        // put in the values to get the JSON reply
        
        guard var url = URL(string: "https://api.foursquare.com/v2/venues/explore?client_id=RSIQCDUUO1CU1NCAWP4J4FXUT150YB3ZERKYIUCEYV3DYMNF&client_secret=NS5FX4EMMRHA3RPEWWOEZLIQ4T2B20WFNAF310GRRQNM3N5U&v=20190701&ll=\(lat),\(lng)&limit=20&section=\(section)") else { return }
        
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
        
        //remove annotation to reset the map
        self.mapView.removeAnnotations(self.mapView.annotations)
        mapView.removeAnnotations(mapView.annotations)
        //get the location
        checkLocationServices()
        
        //Convert Coordinate to String
        let lat = String(format:"%f", pos!.latitude)
        let lng = String(format:"%f", pos!.longitude)
        //replace white space of category to ,
        
        
        let cata = nearbycat as! String
        let cat = cata.replacingOccurrences(of: " ", with: ",")
        //Put in parameters to get approiate JSON reply
        guard let url = URL(string: "https://api.foursquare.com/v2/venues/explore?client_id=RSIQCDUUO1CU1NCAWP4J4FXUT150YB3ZERKYIUCEYV3DYMNF&client_secret=NS5FX4EMMRHA3RPEWWOEZLIQ4T2B20WFNAF310GRRQNM3N5U&v=20190701&opennow=1&sortbydistance=1&ll=\(lat),\(lng)&query=\(cat)") else { return }
        
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
                    
                    
                    self.mapView.removeAnnotations(self.mapView.annotations)

                    
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

