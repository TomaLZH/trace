import UIKit
import FirebaseDatabase
import Firebase
import FirebaseAuth

// id for testing purposes only
let user = "justinMac"

let dateFormatter = DateFormatter()

enum itemType: String {
    case Itinerary = "itineraries/"
    case Day = "itineraries/days"
    case Task = "itineraries/days/tasks"
}


class FirebaseDBController {
    // Inserts or replaces items into Firebase
    static func insertOrReplace(for location: itemType, item: Any) {
        if let item = item as? Itinerary {
            let itineraryId = UUID().uuidString
            var idToUpload = ""
            if item.id == nil {
                idToUpload = itineraryId
            } else {
                idToUpload = item.id!
            }
            let ref = FirebaseDatabase.Database.database().reference().child("\(location.rawValue)\(user)/\(idToUpload)")
            
            ref.setValue([
                "id": idToUpload,
                "name": item.name,
                "country": item.country,
                "startDate": item.startDate,
                "endDate": item.endDate,
                "venue": item.venue
                ])
            
            for i in 1...item.days.count {
                let refDays = FirebaseDatabase.Database.database().reference().child("\(location.rawValue)\(user)/\(idToUpload)/days/\(i)")
                let title = "Day \(i)"
                
                refDays.setValue([
                    "title": title
                    ])
            }
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
                let thisItinerary = Itinerary(id: r.childSnapshot(forPath: "id").value as? String,
                                              name: r.childSnapshot(forPath: "name").value as! String,
                                              country: r.childSnapshot(forPath: "country").value as! String,
                                              startDate: r.childSnapshot(forPath: "startDate").value as! String,
                                              endDate: r.childSnapshot(forPath: "endDate").value as! String,
                                              venue: r.childSnapshot(forPath: "venue").value as? [String] ?? [nil])
                let dbDays =  r.childSnapshot(forPath: "days").value as? [Any] ?? []
                print(dbDays.count)
                
                itineraryList.append(thisItinerary)
            }
            
            onComplete(itineraryList)
        })
    }
    
    static func delete(for location: itemType, item: Any) {
        if let id = item as? String {
            if location == .Itinerary {
                print("deleting for \(location.rawValue)\(user)/\(id)/")
                let ref = FirebaseDatabase.Database.database().reference().child("\(location.rawValue)\(user)/\(id)/")
                
                ref.removeValue()
            }
        }
    }
}
