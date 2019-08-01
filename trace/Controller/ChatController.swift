import UIKit
import ApiAI
import AVFoundation
import CoreLocation

class ChatController: UIViewController {
    let locationManager = CLLocationManager()
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
                //self.retrieveWeather(response)
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
            
            
        case "getweather":
            
             let country = parameters["geo-country"] as? AIResponseParameter
            let city = parameters["geo-city"] as? AIResponseParameter
             
             if country?.stringValue != "" {
             Weather.country = country?.stringValue
             Weather.city = country?.stringValue
                
                if CLLocationManager.locationServicesEnabled(){
                    switch CLLocationManager.authorizationStatus() {
                    case .authorizedAlways, .authorizedWhenInUse:
                        print("Authorized.")
                        let lat = locationManager.location?.coordinate.latitude
                        let long = locationManager.location?.coordinate.longitude
                        let location = CLLocation(latitude: lat!, longitude: long!)
                        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {
                            (placemarks, error)in
                            
                            let weatherGetter = GetWeather()
                            var cityInput = ""
                            if error != nil {
                                return
                            }
                            if country != nil {
                                cityInput = country!.stringValue
                                
                                // let tempCelcius = Weather.celsius
                                // let name = Weather.name
                            }
                            if city != nil {
                                cityInput = city!.stringValue
                            }
                            
                            weatherGetter.getWeather(city: cityInput, onComplete: {
                                DispatchQueue.main.async {
                                    self.tracetext.text = Weather.weather
                                }
                            })
                        })
                    default: break
                    }
                }
                
                
                
             }
            
             else {
          
            if CLLocationManager.locationServicesEnabled(){
                switch CLLocationManager.authorizationStatus() {
                case .authorizedAlways, .authorizedWhenInUse:
                    print("Authorized.")
                    let lat = locationManager.location?.coordinate.latitude
                    let long = locationManager.location?.coordinate.longitude
                    let location = CLLocation(latitude: lat!, longitude: long!)
                    CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error)in
                        if error != nil {
                            return
                        } else if let country = placemarks?.first?.country,
                            let city = placemarks?.first?.locality {
                            print(country)
                            print(city)
                            
                            let weatherGetter = GetWeather()
                            weatherGetter.getWeather(city: city, onComplete: { })
                            
                            // let tempCelcius = Weather.celsius
                            // let name = Weather.name
                            
                            print(Weather.weather!)
                            self.tracetext.text = Weather.weather
                            
                        }
                        
                    })
                    
                default: break
                }
            }
            
        }
            
            
            
        default:
            print("Unmanaged intent.")
        }
    }
    
  /*
    func retrieveWeather(_ response: AIResponse){
        let intent = response.result.metadata.intentName
        let parameters = response.result.parameters

        switch intent {
        case "getweather":
            let country = parameters["geo-country"] as! AIResponseParameter
            let city = parameters["geo-city"] as! AIResponseParameter
            Weather.country = country.stringValue
            if CLLocationManager.locationServicesEnabled(){
                switch CLLocationManager.authorizationStatus() {
                case .authorizedAlways, .authorizedWhenInUse:
                    print("Authorized.")
                    let lat = locationManager.location?.coordinate.latitude
                    let long = locationManager.location?.coordinate.longitude
                    let location = CLLocation(latitude: lat!, longitude: long!)
                    CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error)in
                        if error != nil {
                            return
                        } else if let country = placemarks?.first?.country,
                            let city = placemarks?.first?.locality {
                            print(country)
                            print(city)
                            
                            let weatherGetter = GetWeather()
                            weatherGetter.getWeather(city: city)
                            
                           // let tempCelcius = Weather.celsius
                           // let name = Weather.name
                           
                            
                            
                        }
                        
                    })
                    print(Weather.weather)
                    self.tracetext.text = Weather.weather
                default: break
                }
            }
            
            
            
        default:
            print("Unmanaged intent.")
        
        

        }
    }
    
    
    */
    
    
    
    
    
    
    
}

