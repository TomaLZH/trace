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
    var country: String?
    @IBOutlet weak var deleteButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        datePickerView.datePickerMode = .time
        timeTextField.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(self.datePickerValueChanged), for: UIControl.Event.valueChanged)
        if task != nil {
            setLocationBtn.titleLabel?.text = "Edit Location"
            titleTextField.text = task!.title
            timeTextField.text = task!.time
            venueCoordinates = CLLocationCoordinate2D(latitude: task!.lat, longitude: task!.lng)
            forDay = task!.day
            forItineraryId = task!.itineraryId
            
            deleteButton.isHidden = false
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
            let taskMapController = segue.destination as! TaskMapController
            taskMapController.task = task
            taskMapController.itineraryId = forItineraryId
            taskMapController.coordinatesToEdit = venueCoordinates
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
        let newTask = Task(title: title, taskType: "", time: time, lat: lat, lng: lng)
        newTask.setDay(forDay!)
        newTask.setItineraryId(forItineraryId!)
        newTask.setId(task?.id)
        if newTask.validateTime() {
            FirebaseDBController.insertOrReplace(for: .Task, item: newTask)
            
            navigationController?.popViewController(animated: true)
        }
        else {
            let alert = UIAlertController(title: "Error", message: "Please enter valid time.", preferredStyle: .alert)
            
            alert.addAction(
                UIAlertAction(title: "Okay",
                              style: .default,
                              handler: nil
            ))
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
    
    @IBAction func onDeletePress(_ sender: Any) {
        let alertDelete = UIAlertController(title: "Delete Task", message: "Are you sure you want to delete this task?", preferredStyle: .alert)
        
        alertDelete.addAction(
            UIAlertAction(title: "Yes",
                          style: .default,
                          handler: {
                            (action: UIAlertAction!) in
                            self.deleteTask(self.forItineraryId!, self.forDay!, self.task!.id!)
                            self.navigationController?.popToRootViewController(animated: true)
            }
        ))
        
        alertDelete.addAction(
            UIAlertAction(title: "Cancel",
                          style: .cancel,
                          handler: {
                            (action: UIAlertAction!) in
                            print("Cancelled")
            }
        ))
        
        self.present(alertDelete, animated: true, completion: nil)
    }
    
    func deleteTask(_ forItinerary: String, _ forDay: Int, _ forTask: String) {
        FirebaseDBController.deleteTask(itineraryId: forItinerary,day: forDay,taskId: forTask)
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
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
