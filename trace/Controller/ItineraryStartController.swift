import UIKit

class ItineraryStartController: UIViewController {

    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    
    let startDatePickerView = UIDatePicker()
    let endDatePickerView = UIDatePicker()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        startDatePickerView.datePickerMode = UIDatePicker.Mode.date
        startDateTextField.inputView = startDatePickerView
        startDatePickerView.addTarget(self, action: #selector(self.datePickerValueChanged), for: UIControl.Event.valueChanged)
        
        endDatePickerView.datePickerMode = UIDatePicker.Mode.date
        endDateTextField.inputView = endDatePickerView
        endDatePickerView.addTarget(self, action: #selector(self.datePickerValueChanged), for: UIControl.Event.valueChanged)
    }
    
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
    
    
    @IBAction func onDone(_ sender: Any) {
        guard let country = countryTextField.text else { return }
        guard let startDate = startDateTextField.text else { return }
        guard let endDate = endDateTextField.text else { return }
        
        let newItinerary = Itinerary(country: country,
                                     startDate: startDate,
                                     endDate: endDate,
                                     venue: [nil])
        FirebaseDBController.insertOrReplace(for: .Itinerary, item: newItinerary)
        navigationController?.popViewController(animated: true)
    }
}
