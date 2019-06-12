//
//  ViewController.swift
//  trace
//
//  Created by ITP312 on 28/5/19.
//  Copyright © 2019 NYP. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITabBarDelegate, UITableViewDelegate {

    
    
    var lm : CLLocationManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        lm = CLLocationManager()
        lm?.delegate = self
        lm?.desiredAccuracy = kCLLocationAccuracyBest
        lm?.distanceFilter = 0
        lm?.requestWhenInUseAuthorization()
        
        lm?.startUpdatingLocation()
        // Do any additional setup after loading the view, typically from a nib.
        
        lm = CLLocationManager()
        lm?.delegate = self
        lm?.desiredAccuracy = kCLLocationAccuracyBest
        lm?.distanceFilter = 0
        lm?.requestWhenInUseAuthorization()
        
        lm?.startUpdatingLocation()
        
    }
    
    
    

    
    @IBOutlet weak var mapView: MKMapView!
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var location = locations.last!
        print("\(location.coordinate.latitude), \(location.coordinate.longitude)")
    
        
        var region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: 1000,
            longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }
    
}

