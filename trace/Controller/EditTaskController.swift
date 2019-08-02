import UIKit
import CoreLocation

class EditTaskController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    let datePickerView = UIDatePicker()
    @IBOutlet weak var timeTextField: UITextField!
    var venueCoordinates: CLLocationCoordinate2D?
    @IBOutlet weak var setLocationBtn: UIButton!
    var task: Task?
    var forItineraryId: String?
    var forDay: Int?
    @IBOutlet weak var confirmBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        datePickerView.datePickerMode = .time
        timeTextField.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(self.datePickerValueChanged), for: UIControl.Event.valueChanged)
        
        if task != nil {
            setLocationBtn.titleLabel?.text = "Edit Location"
        }
    }
    
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.calendar = NSCalendar.current
        dateFormatter.timeZone = TimeZone.current
        
        let formattedDate = dateFormatter.string(from: sender.date)
        timeTextField.text = formattedDate
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "setTaskLocation" {
            let taskViewController = segue.destination as! TaskMapController
        }
    }
    
    @IBAction func unwindToEditTask(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? TaskMapController {
            venueCoordinates = sourceViewController.coordinatesPassed
        }
    }
    
    @IBAction func onConfirmPress(_ sender: Any) {
        // Update database with new information
        guard let title = titleTextField.text else { return }
        guard let lat = venueCoordinates?.latitude else { return }
        guard let lng = venueCoordinates?.longitude else { return }
        guard let time = timeTextField.text else { return }
        task = Task(title: title, taskType: "", time: time, lat: lat, lng: lng)
        task?.setDay(forDay!)
        task?.setItineraryId(forItineraryId!)
        FirebaseDBController.insertOrReplace(for: .Task, item: task!)
        
        navigationController?.popViewController(animated: true)
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
