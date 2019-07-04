import UIKit
import FirebaseDatabase
import Firebase

// uid for testing purposes only
//let userID = Auth.auth().currentUser?.uid
let user = "simulator"

enum itemType: String {
    case Itineraries = "itineraries/"
}


class FirebaseDBController {
    // Inserts or replaces items into Firebase
    static func insertOrReplace(for location: itemType, item: Any) {
        if let item = item as? Itinerary {
            let ref = FirebaseDatabase.Database.database().reference().child("\(location.rawValue)\(user)")
            
            ref.setValue([
                "country": item.country,
                "date": item.date,
                "venue": item.venue
                ])
        }
    }
}
