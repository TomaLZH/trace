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

