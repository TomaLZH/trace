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
    
    func factscountry(_ searchterm1: String, _ searchcountry: String){
        let searchterm = searchterm1.lowercased()
        print(searchterm)
        print(searchcountry)
        let searchcountry1 = searchcountry.replacingOccurrences(of: " ", with: "%20")
        
        
        guard var url = URL(string: "https://restcountries.eu/rest/v2/name/\(searchcountry1)") else {return}
        let session = URLSession.shared
        session.dataTask(with: url){(data,response,error) in
            if var response = response {}
            if var data = data{
                do{
                    let output = try JSONSerialization.jsonObject(with: data, options: []) as! NSArray
                    let facts = output[0] as! NSDictionary

                    try DispatchQueue.global(qos: .background).async {
                    print(facts)
                    if searchterm == "time zone" || searchterm == "timezone" {
                        var timezone = facts["timezones"] as! NSArray
                        var timezones = timezone.componentsJoined(by: " ")
                        print(timezones)
                        DispatchQueue.main.async {
                        self.tracetext.text = "The Time Zone for \(searchcountry) is/are \(timezones)"
                    }
                        MapState.searchterm = nil
                        MapState.searchcountry = nil

                        }
                        if searchterm == "currency" {
                            var currency = facts["currencies"] as! NSArray
                            var currency2 = currency[0] as! NSDictionary
                            var currenci = currency2["name"]
                            var currencysymbol = currency2["symbol"]
                            DispatchQueue.main.async {
                                self.tracetext.text = "The currency for \(searchcountry) is \(currenci!), \(currencysymbol!)"
                            }
                            MapState.searchterm = nil
                            MapState.searchcountry = nil


                        }
                        if searchterm == "region" {
                            var region = facts["region"]
                            DispatchQueue.main.async{
                            self.tracetext.text = "\(searchcountry) is in \(region!)!"
                            MapState.searchterm = nil
                                MapState.searchcountry = nil

                            }
                        }
                        
                        if searchterm == "population"{
                            var population = facts["population"]
                            DispatchQueue.main.async{
                                self.tracetext.text = "\(searchcountry) has a population of \(population!) people."
                                MapState.searchterm = nil
                                MapState.searchcountry = nil


                            }
                        }
                        if searchterm == "capital" {
                            var capital = facts["capital"]
                            DispatchQueue.main.async {
                                self.tracetext.text = "The capital of \(searchcountry) is \(capital!)"
                                MapState.searchterm = nil
                                MapState.searchcountry = nil


                            }
                        }
                        
                    }
                }catch{
                    print(error)
                }
            }
        }.resume()
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
            
            
            
        case "factscountry":
            print("Ask Country")
            var searchterm = parameters["searchterm"] as! AIResponseParameter
            var country = parameters["country"] as! AIResponseParameter
            
            MapState.searchterm = searchterm.stringValue
            
            if country.stringValue == ""  {
                self.tracetext.text = "Please enter a country"
            }
            
            if country.stringValue != "" {
                MapState.searchcountry = country.stringValue
            }
            
            if MapState.searchcountry != nil && MapState.searchterm != nil{
                factscountry(MapState.searchterm!, MapState.searchcountry!)
            }
            
            
        case "country":
            var searchcountry = parameters["country"] as! AIResponseParameter
            var searchcity = parameters["city"] as! AIResponseParameter
            
            if MapState.searchterm == nil {
                self.tracetext.text = "Sorry, I do not understand."
            }
            else{
                if searchcountry.stringValue != ""{
                MapState.searchcountry = searchcountry.stringValue
                factscountry(MapState.searchterm!, MapState.searchcountry!)
                }
                if searchcity.stringValue != ""{
                    MapState.searchcountry = searchcity.stringValue
                    factscountry(MapState.searchterm!, MapState.searchcountry!)
                }
            }
            
            
        default:
            print("Unmanaged intent.")
        }
        
        
    }
}

