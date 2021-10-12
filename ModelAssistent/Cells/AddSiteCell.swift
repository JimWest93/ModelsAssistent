import UIKit

class AddSiteCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var siteNameTextField: UITextField!
    @IBOutlet weak var newSiteImage: UIImageView!
    @IBOutlet weak var imagesView: UIView!
    @IBOutlet weak var viewForArrow: UIView!
    @IBOutlet weak var arrowImage: UIImageView!
    
    func configureAddSiteCell(data: AddingSiteItem) {
        
        siteNameTextField.addTarget(nil, action: Selector(("firstResponderAction:")), for: .editingDidEndOnExit)
        nameLabel.text = data.name
        nameLabel.isHidden = data.nameLabelisHiden
        siteNameTextField.isHidden = data.textFieldisHiden
        siteNameTextField.textColor = Color.shared.hex("#D9D9D9")
        newSiteImage.image = UIImage(named: data.imageName)
        imagesView.isHidden = data.imageisHiden
        viewForArrow.isHidden = data.arrowImageisHidden
        viewForArrow.backgroundColor = Color.shared.hex("#353D40")
        arrowImage.tintColor = Color.shared.hex("#D9D9D9")
        imagesView.backgroundColor = Color.shared.hex("#353D40")
        siteNameTextField.text = data.textFieldDefaultText
        siteNameTextField.attributedPlaceholder = NSAttributedString.init(string: "enter the site name", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13)])
        self.backgroundColor = Color.shared.hex("#353D40")
    }
}
