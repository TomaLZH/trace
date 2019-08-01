import UIKit

class ItineraryStartController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    let startDatePickerView = UIDatePicker()
    let endDatePickerView = UIDatePicker()
    
    var itineraryToEdit: Itinerary?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // If screen is loaded to edit existing itinerary, load values
        if itineraryToEdit != nil {
            nameTextField.text = itineraryToEdit?.name
            countryTextField.text = itineraryToEdit?.country
            startDateTextField.text = itineraryToEdit?.startDate
            endDateTextField.text = itineraryToEdit?.endDate
            
            deleteButton.isHidden = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        startDatePickerView.datePickerMode = UIDatePicker.Mode.date
        startDateTextField.inputView = startDatePickerView
        startDatePickerView.addTarget(self, action: #selector(self.datePickerValueChanged), for: UIControl.Event.valueChanged)
        
        endDatePickerView.datePickerMode = UIDatePicker.Mode.date
        endDateTextField.inputView = endDatePickerView
        endDatePickerView.addTarget(self, action: #selector(self.datePickerValueChanged), for: UIControl.Event.valueChanged)
    }
    
    // Show date in the text field when user changes date in picker
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if sender == startDatePickerView {
            startDateTextField.text = dateFormatter.string(from: sender.date)
        }
        else if sender == endDatePickerView {
            endDateTextField.text = dateFormatter.string(from: sender.date)
        }
    }
    
    // Upload data to Firebase and return to previous screen
    @IBAction func onDone(_ sender: Any) {
        guard let name = nameTextField.text else { return }
        guard let country = countryTextField.text else { return }
        guard let startDate = startDateTextField.text else { return }
        guard let endDate = endDateTextField.text else { return }
        
        let newItinerary = Itinerary(id: itineraryToEdit?.id,
                                     name: name,
                                     country: country,
                                     startDate: startDate,
                                     endDate: endDate,
                                     venue: [nil])
        if (!newItinerary.validateDates()) {
            let alert = UIAlertController(title: "Error", message: "Please enter a valid date range", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        newItinerary.new()
        FirebaseDBController.insertOrReplace(for: .Itinerary, item: newItinerary)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func onDelete(_ sender: Any) {
        let alertDelete = UIAlertController(title: "Delete Itinerary", message: "Are you sure you want to delete this itinerary?", preferredStyle: .alert)
        
        alertDelete.addAction(
            UIAlertAction(title: "Yes",
                          style: .default,
                          handler: {
                            (action: UIAlertAction!) in
                            self.deleteItinerary(id: self.itineraryToEdit!.id!)
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
    
    func deleteItinerary(id: String) {
        FirebaseDBController.delete(for: .Itinerary, item: id)
    }
}
