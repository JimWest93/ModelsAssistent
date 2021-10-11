import UIKit

class ImageCell: UICollectionViewCell {
    
    @IBOutlet weak var siteImageView: UIImageView!
    
    func configureImageCell(image: String) {
        
        siteImageView.image = UIImage(named: image)

    }
}
