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
        
        guard let url = URL(string: "https://api.foursquare.com/v2/venues/explore?client_id=5PNCWIYXYGVUNIWYQYVXXMYXE50JG0FVLVOHG0HCCT0DNYGY&client_secret=4MZQUKPM4W3HOUX2WMKEPNWA4VHNNXOY4HWMTEPC0R2VDDLH") else{ return }
        
        
        let session = URLSession.shared
        session.dataTask(with: url){(data,response,error) in
            if let response = response{
                print(response)
            }
            if let data = data{
                print(data)
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
