//
//  geocode.swift
//  trace
//
//  Created by ITP312 on 28/6/19.
//  Copyright © 2019 NYP. All rights reserved.
//

import UIKit

class geocode: UIViewController {

    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var country: UITextField!
    
    @IBOutlet weak var submitaddress: UIButton!
    
    @IBOutlet weak var result: UITextField!
    @IBAction func submitadd(_ sender: Any) {
        guard let country = country.text else { return }
        guard let street = address.text else { return }
        
        print("\(country), \(street)")
        
        // Geocode Address String
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            // Process Response
            self.processResponse(withPlacemarks: placemarks, error: error)
        }
        
        // Update View
        geocodeButton.isHidden = true
        activityIndicatorView.startAnimating()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
