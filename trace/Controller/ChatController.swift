import UIKit
import ApiAI
import AVFoundation


class ChatController: UIViewController {
    var nearbycata: String?
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
    

    @IBAction func nextpap(_ sender: Any) {
  
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
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
        case "findnearest" :
            let cat = parameters["category"] as! AIResponseParameter
            print(cat.stringValue)
            MapState.nearbyCategory = cat.stringValue
            
        case "done-yes": // User has finished creating their itinerary
            let country = parameters["country"] as! AIResponseParameter
            let date = parameters["date"] as! AIResponseParameter
            let itinerary = Itinerary(id: nil,
                                      name: "Default",
                                      country: country.stringValue,
                                      startDate: date.stringValue,
                                      endDate: date.stringValue,
                                      venue: ["List of strings for venues"])
            FirebaseDBController.insertOrReplace(for: .Itinerary, item: itinerary)
        case "search":
            print("search")
            let venue_type = parameters["venue-type"] as! AIResponseParameter
            let venue_title = parameters["venue-title"] as! AIResponseParameter
            let country = parameters["geo-country"] as! AIResponseParameter
            let capital = parameters["geo-capital"] as! AIResponseParameter
            let open = parameters["open"] as! AIResponseParameter
            let city = parameters["geo-city"] as! AIResponseParameter
            let sort = parameters["sort"] as! AIResponseParameter
            
            print(venue_title.stringValue)
            
            if venue_title.stringValue != "" {
                print("VENUE TITLE")
                MapState.searchplace = venue_title.stringValue
                self.tracetext.text = "We have found the searched place! A marker has been marked on your map. Have fun exploring!"
            }
            
            else{
            if venue_type.stringValue != "" {
                MapState.venuetype = venue_type.stringValue
            }
           if venue_title.stringValue != "" {
                MapState.venuetype = venue_title.stringValue
            }
            if country.stringValue != "" {
                MapState.region = country.stringValue
            }
            if capital.stringValue != "" {
                MapState.region = capital.stringValue
            }
            if city.stringValue != "" {
                MapState.region = city.stringValue
            }
            MapState.open = open.stringValue
            MapState.price = sort.stringValue
            self.tracetext.text = "Places that matches these criteria have been marked on your map. Hope you find a good place to go"
            }
        default:
            print("Unmanaged intent.")
        }
    }
}

