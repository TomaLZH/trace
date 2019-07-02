//
//  nearby.swift
//  trace
//
//  Created by ITP312 on 1/7/19.
//  Copyright © 2019 NYP. All rights reserved.
//

import UIKit

class nearby: UIViewController {

    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var section: UITextField!
    @IBOutlet weak var result: UILabel!
    
    
    @IBAction func submitted(_ sender: Any) {
        
        
        guard let url = URL(string: "https://api.foursquare.com/v2/venues/explore?ll=40.7,-74&client_id=5PNCWIYXYGVUNIWYQYVXXMYXE50JG0FVLVOHG0HCCT0DNYGY&client_secret=4MZQUKPM4W3HOUX2WMKEPNWA4VHNNXOY4HWMTEPC0R2VDDLH&v=20190701&near=Singapore&limit=2"
) else{ return }
        
        
        
        let session = URLSession.shared
        session.dataTask(with: url){(data,response,error) in
            if let response = response{
                print(response)
            }
            if let data = data{
                print(data)
                do{
                    

                    let output = try JSONSerialization.jsonObject(with: data, options:[]) as! [String: Any]
                    let venues = output["response"] as! [String: Any]
                    let venues2 = venues["groups"] as! NSArray
      //              let venues3 = venues2[2] as! NSDictionary
                    
                    
                    
                    
                    
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
