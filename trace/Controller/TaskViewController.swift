//
//  TaskViewController.swift
//  trace
//
//  Created by Justin Tey on 04/08/2019.
//  Copyright © 2019 NYP. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class TaskViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    var lm: CLLocationManager?
    var task: Task?
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        timeLabel.text = task?.time
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let timeAsDate = dateFormatter.date(from: task!.time)
        
        dateFormatter.dateFormat = "hh:mm a"
        let timeAsString = dateFormatter.string(from: timeAsDate!)
        timeLabel.text = timeAsString
        
        titleLabel.text = task?.title
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        FirebaseDBController.loadTask(forItinerary: task!.itineraryId!, forDay: task!.day!, forTask: task!.id!) {
            (thisTask) in
            self.timeLabel.text = thisTask.time
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            let timeAsDate = dateFormatter.date(from: thisTask.time)
            
            dateFormatter.dateFormat = "hh:mm a"
            let timeAsString = dateFormatter.string(from: timeAsDate!)
            self.timeLabel.text = timeAsString
            
            self.titleLabel.text = thisTask.title
            
            let loc = CLLocationCoordinate2D(latitude: thisTask.lat, longitude: thisTask.lng)
            let region = MKCoordinateRegion.init(center: loc, latitudinalMeters: 1000, longitudinalMeters: 1000)
            self.mapView.setRegion(region, animated: true)
            
            let newAnnotation = MKPointAnnotation()
            newAnnotation.coordinate = loc
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.addAnnotation(newAnnotation)
        }
    }
    
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
        
        mapView.delegate = self
        mapView.showsUserLocation = false
    }
    
    func createAnnotation() {
        let newAnnotation = MKPointAnnotation()
        newAnnotation.coordinate = CLLocationCoordinate2D(latitude: task!.lat, longitude: task!.lng)
        
        mapView.addAnnotation(newAnnotation)
    }
    
    func centerMap() {
        let loc = CLLocationCoordinate2D(latitude: task!.lat, longitude: task!.lng)
        let region = MKCoordinateRegion.init(center: loc, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editTask" {
            let editTaskController = segue.destination as! EditTaskController
            editTaskController.task = task
        }
    }
    
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
            
            return annotationView
    }
    
}
