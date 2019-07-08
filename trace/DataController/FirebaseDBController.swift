import UIKit
import FirebaseDatabase
import Firebase
import FirebaseAuth

// id for testing purposes only
let user = "justinMac"


let dateFormatter = DateFormatter()

enum itemType: String {
    case Itineraries = "itineraries/"
}


class FirebaseDBController {
    // Inserts or replaces items into Firebase
    static func insertOrReplace(for location: itemType, item: Any) {
        if let item = item as? Itinerary {
            let itineraryId = UUID().uuidString
            let ref = FirebaseDatabase.Database.database().reference().child("\(location.rawValue)\(user)/\(itineraryId)")
            
            ref.setValue([
                "country": item.country,
                "date": item.date,
                "venue": item.venue
                ])
        }
    }
    
    
}
