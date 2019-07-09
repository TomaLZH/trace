import UIKit
import FirebaseDatabase
import Firebase
import FirebaseAuth

// id for testing purposes only
let user = "justinMac"


let dateFormatter = DateFormatter()

enum itemType: String {
    case Itinerary = "itineraries/"
}


class FirebaseDBController {
    // Inserts or replaces items into Firebase
    static func insertOrReplace(for location: itemType, item: Any) {
        if let item = item as? Itinerary {
            let itineraryId = UUID().uuidString
            let ref = FirebaseDatabase.Database.database().reference().child("\(location.rawValue)\(user)/\(itineraryId)")
            
            ref.setValue([
                "country": item.country,
                "startDate": item.startDate,
                "endDate": item.endDate,
                "venue": item.venue
                ])
        }
    }
    
    static func loadItineraries(onComplete: @escaping ([Itinerary]) -> Void) {
        var itineraryList: [Itinerary] = []
        
        let ref = FirebaseDatabase.Database.database().reference().child("itineraries/\(user)")
        
        ref.observeSingleEvent(of: .value, with: {
            (snaphot) in
            
            for record in snaphot.children
            {
                let r = record as! DataSnapshot
                
                itineraryList.append(
                    Itinerary(country: r.childSnapshot(forPath: "country").value as! String,
                              startDate: r.childSnapshot(forPath: "startDate").value as! String,
                              endDate: r.childSnapshot(forPath: "endDate").value as! String,
                              venue: r.childSnapshot(forPath: "venue").value as? [String] ?? [nil]
                    )
                )
            }
            
            onComplete(itineraryList)
        })
    }
    
}
