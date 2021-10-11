import UIKit

protocol PercentageDelegate {
    
    func percentageUpdate(percentage: Int)
    
}

class SettingsViewController: UIViewController {

    @IBOutlet weak var settingsTable: UITableView!
    
    var alertControllerPercentage = UIAlertController()
    var alertControllerExchangeRate = UIAlertController()
    
    lazy var settings = ItemsForSettings.itemsForSettings()
    
    var delegate: PercentageDelegate?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        settingsTable.delegate = self
        settingsTable.dataSource = self
        settingsTable.tableFooterView = UIView()
        alertControllerPercentageSetup()
        alertControllerExchangeRateSetup()
        settingsTable.backgroundColor = Color.shared.hex("#A1A5A6")
        view.backgroundColor = Color.shared.hex("#A1A5A6")
        
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }

    }
    
    //защита от введения букв в аллерте процента
    @objc func intValidation(sender: UITextField) {
        
        if Int(sender.text!) != nil {
            
            alertControllerPercentage.actions.first?.isEnabled = true
        
        } else { alertControllerPercentage.actions.first?.isEnabled = false }
        
    }
    
    //защита от букв в аллерте курса обмена
    @objc func doubleValidation(sender: UITextField) {
        
        sender.text = sender.text?.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil)
        
        if Double(sender.text!) != nil {
            
            alertControllerExchangeRate.actions.first?.isEnabled = true
        
        } else { alertControllerExchangeRate.actions.first?.isEnabled = false }
        
    }
    
    //алерт контроллер для изменения курса обмена
    func alertControllerExchangeRateSetup() {
        
        self.alertControllerExchangeRate = UIAlertController(title: "Введите курс конверсии", message: "€ в $", preferredStyle: .alert)
        self.alertControllerExchangeRate.addTextField { (textField) in
            textField.keyboardType = .decimalPad
            textField.addTarget(self, action: #selector(self.doubleValidation), for: .allEditingEvents)
            
        }
        
        let actionCancel = UIAlertAction(title: "Отмена", style: .cancel) { (action) in
            self.alertControllerExchangeRate.dismiss(animated: true, completion: nil)
        }
        
        let actionDone = UIAlertAction(title: "Готово", style: .default) { (action) in
            try! MyRealm.realm.write {
                guard let newExchangeRate = Double((self.alertControllerExchangeRate.textFields?.first?.text)!) else { return }
                MyRealm.realm.objects(ExchangeRate.self).first!.exchangeRate = newExchangeRate
                self.settings[2].infoLableText = "\(newExchangeRate)"
            }
            self.settingsTable.reloadData()
        }
        
        alertControllerExchangeRate.addAction(actionDone)
        alertControllerExchangeRate.addAction(actionCancel)
        
    }
    
    
    //алерт контроллер для изменения процента
    func alertControllerPercentageSetup() {
    
        self.alertControllerPercentage = UIAlertController(title: "Введите процент", message: "Целое число", preferredStyle: .alert)
        self.alertControllerPercentage.addTextField { (textField) in
            textField.keyboardType = .numberPad
            textField.addTarget(self, action: #selector(self.intValidation), for: .allEditingEvents)
            
        }
        
        let actionCancel = UIAlertAction(title: "Отмена", style: .cancel) { (action) in
            self.alertControllerPercentage.dismiss(animated: true, completion: nil)
        }
        
        let actionDone = UIAlertAction(title: "Готово", style: .default) { (action) in
            
            guard let newPercentage = Int((self.alertControllerPercentage.textFields?.first?.text)!) else { return }
            
            try! MyRealm.realm.write {
                MyRealm.realm.objects(ModelPercentage.self).first!.percentage = newPercentage
                self.settings[1].infoLableText = "\(newPercentage)%"
            }
            
            self.settingsTable.reloadData()
            self.delegate?.percentageUpdate(percentage: newPercentage)
            print(newPercentage)
        }
        
        alertControllerPercentage.addAction(actionDone)
        alertControllerPercentage.addAction(actionCancel)
    }
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell") as! SettingsCell
        cell.configureSettingsCell(data: settings[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let sitesInSettingsVC = (storyboard?.instantiateViewController(identifier: "sitesInSettingsVC")) as? SitesSettingsViewController else {return}
        
        switch indexPath.row {
        case 0: self.navigationController?.pushViewController(sitesInSettingsVC, animated: true)
        case 1: self.present(alertControllerPercentage, animated: true, completion: nil)
        case 2: self.present(alertControllerExchangeRate, animated: true, completion: nil)
        default: return
        }
    }

    
}
