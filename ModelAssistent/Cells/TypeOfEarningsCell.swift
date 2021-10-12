import UIKit

class TypeOfEarningsCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    func configureAddSiteCell(data: String) {
        
        nameLabel.text = data
        nameLabel.textColor = Color.shared.hex("#D9D9D9")
        self.backgroundColor = Color.shared.hex("#353D40")
        
    }
    
}
