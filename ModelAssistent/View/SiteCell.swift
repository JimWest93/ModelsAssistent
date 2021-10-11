import UIKit

class SiteCell: UITableViewCell {
    
    @IBOutlet weak var siteNameLabel: UILabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var earningsTextField: UITextField!
    @IBOutlet weak var siteImageView: UIImageView!
    
    var usePercentageCellState: Bool?
    
    func configureSiteCell(data: SiteForTable) {
        earningsTextField.addTarget(nil, action: Selector(("firstResponderAction:")), for: .editingDidEndOnExit)
        siteNameLabel.text = data.name
        currencyLabel.text = data.currency.rawValue
        siteImageView.image = UIImage(named: data.image)
        usePercentageCellState = data.usePercentage
        self.backgroundColor = Color.shared.hex("#353D40")
    }
     
    func configureSiteCellifEdit(data: Earning) {
        
        let imageName = MyRealm.realm.objects(SiteForTable.self).filter("name = '\(data.siteName)'").first?.image ?? "image100"
        
        earningsTextField.addTarget(nil, action: Selector(("firstResponderAction:")), for: .editingDidEndOnExit)
        siteNameLabel.text = data.siteName
        currencyLabel.text = data.currency
        siteImageView.image = UIImage(named: imageName)
        usePercentageCellState = data.usePercentage
        self.backgroundColor = Color.shared.hex("#353D40")
        
        if data.earningWithoutPercentage != 0.0 {
            
            earningsTextField.text = NSNumber(value: data.earningWithoutPercentage).stringValue
        }
    }
}


