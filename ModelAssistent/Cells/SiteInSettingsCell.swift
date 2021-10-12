import UIKit

class SiteInSettingsCell: UITableViewCell {

    @IBOutlet weak var siteImageView: UIImageView!
    @IBOutlet weak var siteNameLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var arrowImage: UIImageView!
    
    func configureSiteInSettingsCell(data: SiteForTable) {
        
        currencyLabel.text = data.siteCurrency
        siteNameLabel.text = data.name
        siteImageView.image = UIImage(named: data.image)
        
        siteNameLabel.textColor = Color.shared.hex("#D9D9D9")
        currencyLabel.textColor = Color.shared.hex("#D9D9D9")
        arrowImage.tintColor = Color.shared.hex("#D9D9D9")

        self.backgroundColor = Color.shared.hex("#353D40")
    }
}
