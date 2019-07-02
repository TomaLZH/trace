//
//  geocode.swift
//  trace
//
//  Created by ITP312 on 28/6/19.
//  Copyright © 2019 NYP. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseDatabase

class geocode: UIViewController {
    lazy var geocoder = CLGeocoder()
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var country: UITextField!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    @IBOutlet weak var submitaddress: UIButton!
    
    @IBOutlet weak var result: UITextField!
    
    var ref: DatabaseReference?
    var databaseHandle: DatabaseHandle?
    
    var newpost = [String]()
    
    @IBAction func submitadd(_ sender: Any) {
        guard let country = country.text else { return }
        guard let street = self.address.text else { return }
        
        // Create Address String
        let address = "\(country), \(street)"
        
        // Geocode Address String
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            // Process Response
            self.processResponse(withPlacemarks: placemarks, error: error)
        }
        
        // Update View
        submitaddress.isHidden = true
        activityIndicatorView.startAnimating()
        
    }
    //aaaa
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref  = Database.database().reference()
        
        databaseHandle = ref?.child("data").observe(.childAdded, with: { (snapshot) in
            //code to execute when child is added
            //take the snapshot and add it to the array
            print(snapshot)
            //convert data to string
            let post = snapshot.value as? String
            
            if let actualpost = post{
                self.newpost.append(actualpost)
            }
            
            
            
        })
        
        // Do any additional setup after loading the view.
    }
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        // Update View
        submitaddress.isHidden = false
        activityIndicatorView.stopAnimating()
        
        if let error = error {
            print("Unable to Forward Geocode Address (\(error))")
            result.text = "Unable to Find Location for Address"
            
        } else {
            var location: CLLocation?
            
            if let placemarks = placemarks, placemarks.count > 0 {
                location = placemarks.first?.location
            }
            
            if let location = location {
                let coordinate = location.coordinate
                result.text = "\(coordinate.latitude), \(coordinate.longitude)"
            } else {
                result.text = "No Matching Location Found"
            }
        }
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
