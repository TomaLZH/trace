import UIKit
import ApiAI
import AVFoundation


class ChatController: UIViewController {

    @IBOutlet weak var tracetext: UILabel!
    @IBOutlet weak var inputtext: UITextField!
    
    @IBAction func entermessage(_ sender: Any) {
        let request = ApiAI.shared().textRequest()
        
        if let text = self.inputtext.text, text != "" {
            request?.query = text
        } else {
            return
        }
        
        request?.setMappedCompletionBlockSuccess({ (request, response) in
            let response = response as! AIResponse
            if let msg = response.result.fulfillment.messages[0] as NSDictionary? {
                self.speechAndText(text: msg.value(forKey: "speech") as! String)
                self.manageResponse(response)
            }
        }, failure: { (request, error) in
            print(error!)
        })
        
        ApiAI.shared().enqueue(request)
        inputtext.text = ""
    }
    


    var list : [String] = []
    
    @IBAction func go(_ sender: Any) {
        
        
        //ATTRACTIONS NEARBY
        guard let url = URL(string: "https://api.foursquare.com/v2/venues/explore?ll=40.7,-74&client_id=5PNCWIYXYGVUNIWYQYVXXMYXE50JG0FVLVOHG0HCCT0DNYGY&client_secret=4MZQUKPM4W3HOUX2WMKEPNWA4VHNNXOY4HWMTEPC0R2VDDLH&v=20190701&near=Bedok&limit=10") else{ return }
        
        
        
        let session = URLSession.shared
        session.dataTask(with: url){(data,response,error) in
            if let response = response{
                
            }
            if let data = data{
                
                do{
                    
                    
                    let output = try JSONSerialization.jsonObject(with: data, options:[]) as! [String:Any]
                    let venues = output["response"] as! NSDictionary
                    let venues2 = venues["groups"] as! NSArray
                    var venues3 = venues2.value(forKeyPath: "items.venue.name") as! NSArray
                    var list = venues3[0] as! NSArray
                    
                    for i in 0..<list.count{
                        print(list[i])
                    }
                    
                    var lats = venues2.value(forKeyPath: "items.venue.location.lat") as! NSArray
                    print(lats)
                    
                    var longs = venues2.value(forKeyPath: "items.venue.location.lng") as! NSArray
                    print(longs)
                    
                    
                    
                    
                   // print(attraction)
                    DispatchQueue.main.async {
                        
                        
                    //    self.resultattrac.text = "\(attraction)"
                    }
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
    
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mwam"{
            let detailvc = segue.destination as! NavigationController
            let last = list
            detailvc.arraya = last
        }
    }
    
    
    
    
    let speechSynthesizer = AVSpeechSynthesizer()
    
    func speechAndText(text: String) {
        let speechUtterance = AVSpeechUtterance(string: text)
        speechSynthesizer.speak(speechUtterance)
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseInOut, animations: {
            self.tracetext.text = text
        }, completion: nil)
    }
    
    // This function will check the intent of the response and do things if need be
    func manageResponse(_ response: AIResponse) {
        let intent = response.result.metadata.intentName
        let parameters = response.result.parameters!
        
        switch intent {
        case "done-yes": // User has finished creating their itinerary
            let country = parameters["country"] as! AIResponseParameter
            let date = parameters["date"] as! AIResponseParameter
            let itinerary = Itinerary(country: country.stringValue,
                                      date: date.stringValue,
                                      venue: ["List of strings for venues"])
            FirebaseDBController.insertOrReplace(for: .Itineraries, item: itinerary)
        default:
            print("Unmanaged intent.")
        }
    }
}

