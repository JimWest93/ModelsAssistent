import UIKit

protocol SitesEarningDelegate {
    func reloadData(date: String, deleted: Bool)
}

class SitesEarningsViewController: UIViewController {
    
    @IBOutlet weak var siteTable: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var percentageTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var hoursOnlineTextField: UITextField!
    @IBOutlet weak var deleteDay: UIButton!  {
        didSet { if editEarning == false {
            deleteDay.isHidden = true
        } else { deleteDay.isHidden = false }
        }
    }
    
    var alertController = UIAlertController()
    
    var editEarning = false
    
    var dateForDateLabel = Date()
    
    var delegate: SitesEarningDelegate?
    
    let dateFormatterMonthDay: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "LLLL dd"
        return dateFormatter
    }()
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "dd MM YYYY"
        return dateFormatter
    }()
    
    lazy var sitesForTable = SiteForTable.currentSites
    lazy var sitesForTableIfEdit = Earning.oneDayObjects(date: dateFormatter.string(from: dateForDateLabel))
    
    override func viewDidLoad() {
        
        overrideUserInterfaceStyle = .light
        
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        siteTable.delegate = self
        siteTable.dataSource = self
        self.dateLabel.text = dateFormatterMonthDay.string(from: dateForDateLabel).firstUppercased
        siteTable.tableFooterView = UIView()
        
        alertControllerSetup()
        siteTable.backgroundColor = Color.shared.hex("#D9D9D9")
        
        hoursOnlineTextField.addTarget(self, action: #selector(self.doubleValidation), for: .allEditingEvents)
        
        percentageTextField.addTarget(self, action: #selector(self.intValidation), for: .allEditingEvents)
        
        percentageTextField.text = "\(MyRealm.realm.objects(ModelPercentage.self).first!.percentage)"
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(randomTap))
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func randomTap() {
         self.view.endEditing(true)
    }

    
    //кнопка полного удаления дня
    @IBAction func deleteAction(_ sender: Any) {
        self.present(alertController, animated: true, completion: nil)
    }
    
    //кнопка сохранить заработок
    @IBAction func saveAction(_ sender: Any) {
        if !editEarning {
            saveEarning()
        } else {
            try! MyRealm.realm.write {
                MyRealm.realm.delete(Earning.oneDayObjects(date: self.dateFormatter.string(from: dateForDateLabel)))
            }
            saveEarning()
        }
    }
    
    //алерт контроллер удаления дня
    func alertControllerSetup() {
        
        self.alertController = UIAlertController(title: "Подтвердите удаление", message: "Вы действительно хотите полностью удалить информацию о заработке в этот день?", preferredStyle: .alert)
        
        let actionCancel = UIAlertAction(title: "Отмена", style: .cancel) { (action) in
            self.alertController.dismiss(animated: true, completion: nil)
        }
        
        let actionYes = UIAlertAction(title: "Да", style: .default) { (action) in
            try! MyRealm.realm.write {
                MyRealm.realm.delete(Earning.oneDayObjects(date: self.dateFormatter.string(from: self.dateForDateLabel)))
            }
            let date = self.dateFormatter.string(from: self.dateForDateLabel)
            self.delegate?.reloadData(date: date, deleted: true)
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(actionYes)
        alertController.addAction(actionCancel)
    }
    
    //сохранение заработка
    func saveEarning() {
        try! MyRealm.realm.write {
            
            for cell in self.siteTable.visibleCells {
                
                let cell = cell as! SiteCell
                let earning = Earning(currency: cell.currencyLabel.text ?? "",
                                      hoursOnline: Double(hoursOnlineTextField.text ?? "1"),
                                      siteName: cell.siteNameLabel.text ?? "",
                                      date: self.dateForDateLabel,
                                      percentage: Int(percentageTextField.text ?? "100")!,
                                      earningInSiteCurrency: Double(cell.earningsTextField.text ?? "0"),
                                      conversion: ExchangeRate.exchangeRate,
                                      usePercentage: cell.usePercentageCellState!)
                
                MyRealm.realm.add(earning)
            }
        }
        let date = dateFormatter.string(from: dateForDateLabel)
        delegate?.reloadData(date: date, deleted: false)
        self.dismiss(animated: true, completion: nil)
    }
    
    //кнопка назад
    @IBAction func backToCalendar(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //защита от введения букв в поле заработка и часов
    @objc func doubleValidation(sender: UITextField) {
        
        sender.text = sender.text?.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil)
        
        if Double(sender.text!) != nil || sender.text!.isEmpty {
            
            saveButton.isEnabled = true
            sender.textColor = .label
            
        } else { saveButton.isEnabled = false
            sender.textColor = .red
        }
        
    }
    
    @objc func intValidation(sender: UITextField) {
        
        if Int(sender.text!) != nil  {
            
            saveButton.isEnabled = true
            sender.textColor = .label
            
        } else { saveButton.isEnabled = false
            sender.textColor = .red
        }
        
    }
    
}


//делегат, датасорс
extension SitesEarningsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.editEarning == true {
            return sitesForTableIfEdit.count
        } else { return sitesForTable.count }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "siteCell") as! SiteCell
        
        if self.editEarning == true {
            
            cell.configureSiteCellifEdit(data: sitesForTableIfEdit[indexPath.row])
            self.hoursOnlineTextField.text = NSNumber(value: sitesForTableIfEdit.first?.hoursOnline ?? 0).stringValue
            self.percentageTextField.text = "\(sitesForTableIfEdit.first?.percentage ?? ModelPercentage.percentage)"
            
        } else { cell.configureSiteCell(data: sitesForTable[indexPath.row]) }
        
        cell.earningsTextField.addTarget(self, action: #selector(doubleValidation), for: .allEditingEvents)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)	
    }
}
