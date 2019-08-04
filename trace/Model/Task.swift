import Foundation

class Task {
    var title: String
    var taskType: String
    var time: String
    var lat: Double
    var lng: Double
    var itineraryId: String?
    var day: Int?
    var id: String?
    
    init(title: String, taskType: String, time: String, lat: Double, lng: Double) {
        self.title = title
        self.taskType = taskType
        self.time = time
        self.lat = lat
        self.lng = lng
    }
    
    func setItineraryId(_ id: String) {
        itineraryId = id
    }
    
    func setDay(_ onDay: Int) {
        day = onDay
    }
    
    func setId(_ newId: String?) {
        id = newId
    }
    
    func validateTime() -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        let timeAsDate = dateFormatter.date(from: time)
        if timeAsDate == nil {
            return false
        }
        return true
    }
}
