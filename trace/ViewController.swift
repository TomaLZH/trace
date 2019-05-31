//
//  ViewController.swift
//  trace
//
//  Created by ITP312 on 28/5/19.
//  Copyright © 2019 NYP. All rights reserved.
//

import UIKit
import CoreLocation


class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var lm : CLLocationManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        lm = CLLocationManager()
        lm?.delegate = self
        lm?.desiredAccuracy = kCLLocationAccuracyBest
        lm?.distanceFilter = 0
        lm?.requestWhenInUseAuthorization()
        
        lm?.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        var location = locations.last!
    }
    
    


}

