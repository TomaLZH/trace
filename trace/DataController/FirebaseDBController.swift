import UIKit
import FirebaseDatabase
import Firebase
import FirebaseAuth

// id
let user = "justinMac"

let dateFormatter = DateFormatter()

enum itemType: String {
    case Itinerary = "itineraries/"
    case Day = "itineraries/days"
    case Task = "itineraries/tasks"
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
        else if let item = item as? Task {
            let taskId = UUID().uuidString
            var idToUpload = ""
            if item.id == nil {
                idToUpload = taskId
            } else {
                idToUpload = item.id!
            }
            let ref = FirebaseDatabase.Database.database().reference().child("itineraries/\(user)/\(item.itineraryId!)/days/\(item.day!)/\(idToUpload)")
            ref.setValue([
                "id": idToUpload,
                "title": item.title,
                "time": item.time,
                "type": item.taskType,
                "lat": item.lat,
                "lng": item.lng
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
                let thisItinerary = Itinerary(id: r.childSnapshot(forPath: "id").value as? String,
                                              name: r.childSnapshot(forPath: "name").value as! String,
                                              country: r.childSnapshot(forPath: "country").value as! String,
                                              startDate: r.childSnapshot(forPath: "startDate").value as! String,
                                              endDate: r.childSnapshot(forPath: "endDate").value as! String,
                                              venue: r.childSnapshot(forPath: "venue").value as? [String] ?? [nil])
                itineraryList.append(thisItinerary)
            }
            
            onComplete(itineraryList)
        })
    }
    
    static func loadTasks(forItinerary: String, forDay: Int, onComplete: @escaping ([Task]) -> Void) {
        var taskList: [Task] = []
        
        let ref = FirebaseDatabase.Database.database().reference().child("itineraries/\(user)/\(forItinerary)/days/\(forDay)")
        
        ref.observeSingleEvent(of: .value, with: {
            (snaphot) in
            print("YES")
            for record in snaphot.children
            {
                let r = record as! DataSnapshot
                let thisTask = Task(title: r.childSnapshot(forPath: "title").value as! String,
                                    taskType: r.childSnapshot(forPath: "type").value as! String,
                                    time: r.childSnapshot(forPath: "time").value as? String ?? "Type",
                                    lat: r.childSnapshot(forPath: "lat").value as? Double ?? 0,
                                    lng: r.childSnapshot(forPath: "lng").value as? Double ?? 0)
                thisTask.id = r.childSnapshot(forPath: "id").value as? String
                taskList.append(thisTask)
            }
            
            onComplete(taskList)
        })
    }
    
    static func getTasks(forItinerary: String, forDay: Int) -> [Task] {
        var taskList: [Task] = []
        
        let ref = FirebaseDatabase.Database.database().reference().child("itineraries/\(user)/\(forItinerary)/days/\(forDay)/")
        
        ref.observeSingleEvent(of: .value, with: {
            (snaphot) in
            
            for record in snaphot.children
            {
                let r = record as! DataSnapshot
                let thisTask = Task(title: r.childSnapshot(forPath: "title").value as? String ?? "Title",
                                    taskType: r.childSnapshot(forPath: "type").value as? String ?? "Type",
                                    time: r.childSnapshot(forPath: "time").value as? String ?? "Type",
                                    lat: r.childSnapshot(forPath: "lat").value as? Double ?? 0,
                                    lng: r.childSnapshot(forPath: "lng").value as? Double ?? 0
                                    )
                thisTask.id = r.childSnapshot(forPath: "id").value as? String
                taskList.append(thisTask)
            }
        })
        
        return taskList
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
