import UIKit

// Things we need to have for parent cell
struct cellData {
    var isOpened = Bool()
    var title = String()
    var sectionData = [Task]()
}

class ItineraryViewController: UITableViewController, DayCellDelegate {
    func newTaskTapped(cell: DayCell) {
        let indexPath = self.tableView.indexPath(for: cell)
        let day = indexPath!.section + 1
        tappedDay = day
    }
    
    var tappedDay: Int?
    var tableViewData = [cellData]()
    var itinerary: Itinerary?
    var listOfTasks = [[Task]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let noOfDays = itinerary?.numberOfDays() {
            for i in 1...noOfDays {
                //                FirebaseDBController.loadTasks(forItinerary: itinerary?.id ?? "", forDay: i) {
                //                    (taskList) in
                //                    self.listOfTasks.append(taskList)
                //                }
                let taskList = FirebaseDBController.getTasks(forItinerary: itinerary?.id ?? "", forDay: i)
                self.listOfTasks.append(taskList)
            }
            for i in 0...listOfTasks.count-1 {
                let dayTasks = listOfTasks[i]
                if dayTasks.count > 0 {
                    for j in 0...dayTasks.count {
                        let task = dayTasks[j]
                    }
                }
                let dayCell = cellData(isOpened: false, title: "Day \(i+1)", sectionData: dayTasks)
                tableViewData.append(dayCell)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        navigationItem.title = itinerary?.name
    }
    
    // number of sections is equal to the number of parent cells(days)
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewData.count
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableViewData[section].isOpened == true {
            return tableViewData[section].sectionData.count + 1
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataIndex = indexPath.row - 1
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "dayCell") as! DayCell
            cell.delegate = self
            cell.dayLabel.text = tableViewData[indexPath.section].title
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell") as! TaskCell
            cell.taskLabel.text = tableViewData[indexPath.section].sectionData[dataIndex].title
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // if parent cell(day) is tapped
        if indexPath.row == 0 {
            // handle expanding and minimising cell groups
            if tableViewData[indexPath.section].isOpened == true {
                tableViewData[indexPath.section].isOpened = false
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            } else {
                tableViewData[indexPath.section].isOpened = true
                let sections = IndexSet.init(integer: indexPath.section)
                tableView.reloadSections(sections, with: .none)
            }
        }
            // else when child cell(task) is tapped
        else {
            // go to edit screen of task
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editItinerary" {
            let itineraryEditController = segue.destination as! ItineraryStartController
            itineraryEditController.itineraryToEdit = itinerary
        }
        else if segue.identifier == "newTask" {
            let editTaskController = segue.destination as! EditTaskController
            
            if tappedDay != nil {
                editTaskController.forDay = tappedDay
                editTaskController.forItineraryId = itinerary?.id
            }
        }
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
