import UIKit

class SettingsCell: UITableViewCell {

    @IBOutlet weak var settingNameLabel: UILabel!
    @IBOutlet weak var settingInfoLabel: UILabel!
    @IBOutlet weak var arrowImage: UIImageView!
    
    func configureSettingsCell(data: SettingItem) {
        
        settingNameLabel.text = data.name
        settingInfoLabel.isHidden = data.infoLableIsHidden
        settingInfoLabel.text = data.infoLableText
        
        settingInfoLabel.textColor = Color.shared.hex("#D9D9D9")
        settingNameLabel.textColor = Color.shared.hex("#D9D9D9")
        arrowImage.tintColor = Color.shared.hex("#D9D9D9")
        
        self.backgroundColor = Color.shared.hex("#353D40")
        
    }
}
