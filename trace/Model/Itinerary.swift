import Foundation

class Itinerary {
    var id: String?
    var name: String
    var country: String
    var startDate: String
    var endDate: String
    var venue: [String?]
    var days: [Day] = []
    
    init(id: String?, name: String, country: String, startDate: String, endDate: String, venue: [String?]) {
        self.id = id
        self.name = name
        self.country = country
        self.startDate = startDate
        self.endDate = endDate
        self.venue = venue
    }
    
    func new() {
        newDays()
    }
    
    func newDays() {
        let noOfDays = numberOfDays()
        
        for i in 1...noOfDays {
            days.append(Day(title: "Day \(i)"))
        }
    }
    
    func validateDates() -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let start = dateFormatter.date(from: startDate)
        let end = dateFormatter.date(from: endDate)
        
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.day], from: start!, to: end!)
        let noOfDays = components.day! + 1
        
        if noOfDays < 1 {
            return false
        }
        else
        {
            return true
        }
    }
    
    func setDays(days: [Day]) {
        self.days = days
    }
    
    func numberOfDays() -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let start = dateFormatter.date(from: startDate)
        let end = dateFormatter.date(from: endDate)
        
        // Calculate number of days
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.day], from: start!, to: end!)
        let noOfDays = components.day! + 1
        
        return noOfDays
    }
}
