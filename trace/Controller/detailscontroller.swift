import UIKit

class detailscontroller: UIViewController {
    var isopen: String?
    var latitude: Double?
    var longitude : Double?
    var placeid: String?
    var open: String = "No Opening Time Found"
    var isopenarray: [String] = []
    enum foursquareerror : Error{
        case nopicturefound
    }
    
    
    @IBOutlet weak var openorclose: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var addresslabel: UILabel!
    @IBOutlet weak var openingtime: UILabel!
    @IBOutlet weak var descriptionlabel: UILabel!
    @IBOutlet weak var imageplace: UIImageView!
    @IBOutlet weak var namelabel: UILabel!
    @IBAction func getdirections(_ sender: Any) {
        MapState.placesID = placeid
        print(MapState.placesID)
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "navigation") as? NavigationController
        self.navigationController?.pushViewController(vc!, animated: true)
        
        
        
    }
    @IBOutlet weak var ratinglabel: UILabel!
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
        guard var url = URL(string: "https://api.foursquare.com/v2/venues/search?\(MapState.apikeys!)&v=20190701&ll=\(lat),\(long)") else { return }
        
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
        var ids = placeid as? String ?? "nil"
        if ids == "nil"{
            self.addresslabel.text  = "No Data Found"
            self.ratinglabel.text = "No Data Found"
            self.namelabel.text = "No Data Found"
        }
            
        else{
            guard var url = URL(string: "https://api.foursquare.com/v2/venues/\(ids)?\(MapState.apikeys!)&v=20190715") else { return }
            
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
                            let photo: NSDictionary? = venues2["photos"] as? NSDictionary
                            let photo2: NSArray? = photo?["groups"] as? NSArray
                            if photo2!.count > 1{
                                let photo3: NSDictionary? = photo2?[1] as? NSDictionary
                                let photo4: NSArray? = photo3?["items"] as? NSArray
                                let photo5: NSDictionary? = photo4?[0] as? NSDictionary
                                print("it isnt empty")
                                let prefix = photo5?["prefix"] as! String
                                let suffix = photo5?["suffix"] as! String
                                let links = prefix+"383x303"+suffix
                                let link = URL(string: links)
                                let data = try Data(contentsOf: link!)
                                DispatchQueue.main.async {
                                    self.imageplace?.image = UIImage(data:data)
                                }
                            }
                            
                            
                            //assign the values retrieved
                            var rating1 = "BLAH BLAH"
                            //get address
                            let address = venues2["location"] as! NSDictionary
                            let address2 = address["address"] as? String ?? "No Address Found"
                            
                            //get rating
                            var rating = venues2["rating"] as? NSNumber ?? 0
                            
                            //convert NSNumber to String
                            if rating == 0{
                                rating1 = "No Ratings Found"
                            }
                            else{
                                let formatter = NumberFormatter()
                                formatter.numberStyle = .decimal
                                formatter.maximumFractionDigits = 1
                                formatter.locale = Locale(identifier: "en")
                                rating1 = formatter.string(from: rating)!
                            }
                            
                            
                            //get opening time and current status
                            if venues2["hour"] != nil{
                                let status = venues2["hour"] as! NSDictionary
                                let isopen1 = status["isOpen"] as! String
                                
                                if isopen1 == "true"{
                                    self.isopen = "Currently Open"
                                }
                                else{
                                    self.isopen = "Currently Closed"
                                }
                            }

                            if venues2["popular"] != nil {
                                let venues3 = venues2["popular"] as! NSDictionary
                                let isopen1 = venues3["isOpen"] as! Bool
                                if isopen1 == true{
                                    self.isopen = "Currently Open"
                                }
                                else{
                                    self.isopen = "Currently Closed"
                                }
                                
                                let status = venues3["timeframes"] as! NSArray
                                for i in 0..<status.count{
                                    let status1 = status[i] as! NSDictionary
                                    let days = status1["days"] as! String
                                    let status2 = status1["open"] as! NSArray
                                    let status3 = status2[0] as! NSDictionary
                                    let time = status3["renderedTime"] as! String
                                    let timing = days + ": " + time
                                    self.isopenarray.append(timing)
                                }
                                self.open = self.isopenarray.joined(separator: "\n")
                            }
                            
                            
                            if venues2["hours"] != nil{
                                let venues3 = venues2["hours"] as! NSDictionary
                                let status = venues3["timeframes"] as! NSArray
                                for i in 0..<status.count{
                                    var status1 = status[i] as! NSDictionary
                                    var days = status1["days"] as! String
                                    var status2 = status1["open"] as! NSArray
                                    var status3 = status2[0] as! NSDictionary
                                    var time = status3["renderedTime"] as! String
                                    var timing = days + ":" + time
                                    self.isopenarray.append(timing)
                                }
                                
                                self.open = self.isopenarray.joined(separator: "\n")
                            }
                            
                            
                            DispatchQueue.main.async {
                                self.openingtime.text = self.open
                                self.openorclose.text = self.isopen
                                self.namelabel.text = name
                                self.addresslabel.text = address2
                                self.ratinglabel.text = (rating1 as! String) + "/10"
                            }
                            
                        }
                        
                    }
                    catch{
                        print(error)
                    }
                    
                }
                }.resume()
        }
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    
    
}
