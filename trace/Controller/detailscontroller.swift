//
//  detailscontroller.swift
//  trace
//
//  Created by ITP312 on 12/7/19.
//  Copyright © 2019 NYP. All rights reserved.
//

import UIKit

class detailscontroller: UIViewController {
    
    var latitude: Double?
    var longitude : Double?
    var placeid: String?
    
    
    @IBOutlet weak var imageplace: UIImageView!
    @IBOutlet weak var namelabel: UILabel!
    
    override func viewDidLoad() {
        
        //getplacedetails(self.id)
        super.viewDidLoad()
        
        var lat:String = String(format:"%f", latitude!)
        var long:String = String(format:"%f",longitude!)
        getplaceID(lat,long)        //getdetails()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print(self.placeid)
        getplacedetails(self.placeid)
    }
    
    
    
    
    func getplaceID(_ lat : String,_ long: String){
        
        
        
        
        // put in the values to get the JSON reply
        guard var url = URL(string: "https://api.foursquare.com/v2/venues/search?client_id=5PNCWIYXYGVUNIWYQYVXXMYXE50JG0FVLVOHG0HCCT0DNYGY&client_secret=4MZQUKPM4W3HOUX2WMKEPNWA4VHNNXOY4HWMTEPC0R2VDDLH&v=20190701&ll=\(lat),\(long)") else { return }
        
        var session = URLSession.shared
        session.dataTask(with: url){(data,response,error) in
            if var response = response {
                
            }
            if var data = data{
                
                do{
                    
                    // Make the JSON readable and go through the array/dictionary to get
                    let output = try JSONSerialization.jsonObject(with: data, options:[]) as! [String:Any]
                    let venues = output["response"] as! NSDictionary
                    let venues2 = venues["venues"] as! NSArray
                    let venues3 = venues2[0] as! NSDictionary
                    let placesid = venues3["id"] as! String?
                    self.placeid = placesid
                    
                    
                    
                } catch{
                    print(error)
                }
                
            }
            }.resume()
    }
    
    
    func getplacedetails(_ placeid: String?){
        
        
        
        print(placeid)
        var ids = placeid as! String
        
        guard var url = URL(string: "https://api.foursquare.com/v2/venues/\(ids)?client_id=5PNCWIYXYGVUNIWYQYVXXMYXE50JG0FVLVOHG0HCCT0DNYGY&client_secret=4MZQUKPM4W3HOUX2WMKEPNWA4VHNNXOY4HWMTEPC0R2VDDLH&v=20190715") else { return }
        
        var session = URLSession.shared
        session.dataTask(with: url){(data,response,error) in
            if var response = response {
            }
            if var data = data{
                do{
                    
                    //get the name
                    var output = try JSONSerialization.jsonObject(with: data, options:[]) as! [String:Any]
                    let venues = output["response"] as! NSDictionary
                    let venues2 = venues["venue"] as! NSDictionary
                    let name = venues2["name"] as! String
                    
                    try DispatchQueue.global(qos: .background).sync {
                        
                        //get the image
                        let photo = venues2["photos"] as! NSDictionary
                        let photo2 = photo["groups"] as! NSArray
                        let photo3 = photo2[1] as! NSDictionary
                        let photo4 = photo3["items"] as! NSArray
                        let photo5 = photo4[0] as! NSDictionary
                        let prefix = photo5["prefix"] as! String
                        let suffix = photo5["suffix"] as! String
                        let links = prefix+"300x300"+suffix
                        let link = URL(string: links)
                        
                        //assign the values retrieved
                        let data = try Data(contentsOf: link!)
                        
                        DispatchQueue.main.async {
                            self.namelabel.text = name
                            self.imageplace.image = UIImage(data:data)
                            
                            
                        }
                        
                    }
                    
                }
                catch{
                    print(error)
                }
                
            }
            }.resume()
        
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
