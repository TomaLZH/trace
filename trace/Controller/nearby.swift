//
//  nearby.swift
//  trace
//
//  Created by ITP312 on 1/7/19.
//  Copyright © 2019 NYP. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseDatabase

class nearby: UIViewController, UITableViewDelegate {

    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var section: UITextField!
    @IBOutlet weak var resultcoor: UILabel!
    @IBOutlet weak var resultattrac: UILabel!
    
//
 @IBAction func submitted(_ sender: Any) {
//        //GEOCODING
//            guard let country = country else { return }
//            guard let street = street else { return }
//            
//            // Create Address String
//            let address = "\(coordinate), \(street)"
//            
//            // Geocode Address String
//            geocoder.geocodeAddressString(address) { (placemarks, error) in
//                // Process Response
//                self.processResponse(withPlacemarks: placemarks, error: error)
//        }
//        
        
        
        
    var attraction: [Any] = []
        
        
        
        //ATTRACTIONS NEARBY
    guard let url = URL(string: "https://api.foursquare.com/v2/venues/explore?ll=40.7,-74&client_id=5PNCWIYXYGVUNIWYQYVXXMYXE50JG0FVLVOHG0HCCT0DNYGY&client_secret=4MZQUKPM4W3HOUX2WMKEPNWA4VHNNXOY4HWMTEPC0R2VDDLH&v=20190701&near=Bedok&limit=10") else{ return }
        
        
        
        let session = URLSession.shared
        session.dataTask(with: url){(data,response,error) in
            if let response = response{
                
            }
            if let data = data{
                
                do{
                    

                    let output = try JSONSerialization.jsonObject(with: data, options:[]) as! [String: Any]
                    let venues = output["response"] as! [String: Any]
                    let venues2 = venues["groups"] as! NSArray
                    let venues3 = venues2.value(forKeyPath: "items.venue.name") as! NSArray
                    let venues4 = venues3[0] as! NSArray
                    for i in 0..<venues4.count{
                    attraction.append(venues4[i])
                    }
                    print(attraction)
                    DispatchQueue.main.async {
                        

                   self.resultattrac.text = "\(attraction)"
                    }
                    //response.group.items.venue.name
                } catch{
                    print(error)
                }
            
            }
        }.resume()
        
        
        
        
        
    
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    private func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        // Update View
        
        if let error = error {
            print("Unable to Forward Geocode Address (\(error))")
            resultcoor.text = "Unable to Find Location for Address"
            
        } else {
            var location: CLLocation?
            
            if let placemarks = placemarks, placemarks.count > 0 {
                location = placemarks.first?.location
            }
            
            if let location = location {
                let coordinate = location.coordinate
                resultcoor.text = "\(coordinate.latitude), \(coordinate.longitude)"
            } else {
                resultcoor.text = "No Matching Location Found"
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
