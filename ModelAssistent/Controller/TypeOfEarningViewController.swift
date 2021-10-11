import UIKit

protocol TypeOfEarningDelegate {
    
    func saveTypeOfEarning(usePercentage: Bool, name: String)
    
}

class TypeOfEarningViewController: UIViewController {
    
    @IBOutlet weak var typeOfEarningTable: UITableView!
    @IBOutlet weak var backButton: UIButton!
    
    let dataForTable = ["Вся сумма идет в доход", "Для расчета дохода использовать процент"]
    
    var delegate: TypeOfEarningDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        typeOfEarningTable.delegate = self
        typeOfEarningTable.dataSource = self
        colors()
        
    }

    @IBAction func dismiss(_ sender: Any) {
        self.dismissDetail()
    }
    
    func colors() {
        
        self.backButton.tintColor = Color.shared.hex("#D9D9D9")
        self.backButton.setTitleColor(Color.shared.hex("#D9D9D9"), for: .normal)
        typeOfEarningTable.backgroundColor = Color.shared.hex("#A1A5A6")
        view.backgroundColor = Color.shared.hex("#A1A5A6")
        
    }
    
}

extension TypeOfEarningViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "typeOfEarningCell") as! TypeOfEarningsCell
        cell.configureAddSiteCell(data: dataForTable[indexPath.row])
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 0: delegate?.saveTypeOfEarning(usePercentage: false, name: dataForTable[0])
            self.dismissDetail()
        case 1: delegate?.saveTypeOfEarning(usePercentage: true, name: dataForTable[1])
            self.dismissDetail()
        default: return
        }
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
       
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
}

extension TypeOfEarningViewController {
    
    func dismissDetail() {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        self.view.window!.layer.add(transition, forKey: kCATransition)

        dismiss(animated: false)
    }
    
}
