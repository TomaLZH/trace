import UIKit

protocol DayCellDelegate: AnyObject {
    func newTaskTapped(cell: DayCell)
}

class DayCell: UITableViewCell {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var newTaskBtn: UIButton!
    
    weak var delegate: DayCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func newTaskTapped(_ sender: Any) {
        delegate?.newTaskTapped(cell: self)
    }
    
}
