import UIKit

protocol sitesInSettingsDelegate {
    func reloadData()
}

class AddSiteViewController: UIViewController {
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var addSiteTable: UITableView!
    @IBOutlet weak var currencyPicker: UIPickerView!
    @IBOutlet weak var currencyPickerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imagesCollection: UICollectionView!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    
    var delegate: sitesInSettingsDelegate?
    
    //свойства для нового сайта
    var nameForNewSite = ""
    var imageForNewSite = ""
    var currencyForNewSite: Currency = .`$`
    var usePercentage: Bool = false
    var typeOfEarningText = ""
    
    //свойства для проверки валидности полей
    var currencySelected = false
    var nameValidation = false
    
    //свойства для изменения сайта
    var indexOfSiteInRealm = 0
    var changingTheSite = false
    var typeEditing = false
    
    //свойства для заполнения таблицы
    var addSiteItems = ItemsToAddSite.itemsForSiteAdding()
    let currency = [Currency.`$`.rawValue, Currency.tk.rawValue, Currency.€.rawValue]
    
    let images = (0...49).compactMap {"image\($0)"}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        
        currencyPicker.dataSource = self
        currencyPicker.delegate = self
        
        imagesCollection.delegate = self
        imagesCollection.dataSource = self
        
        addSiteTable.delegate = self
        addSiteTable.dataSource = self
        
        currencyPickerHeightConstraint.constant = 0
        
        currencyPicker.isHidden = true
        imagesCollection.isHidden = true
        warningLabel.isHidden = true
        
        warningLabel.textColor = .red
        
        validationCheck()
        addChangeButtonName()
        valuesForVariables()
        colors()
        
        addSiteTable.tableFooterView = UIView()
        
    }
    
    //цвета
    func colors() {
        
        addButton.tintColor = Color.shared.hex("#D9D9D9")
        cancelButton.tintColor = Color.shared.hex("#D9D9D9")
        addSiteTable.backgroundColor = Color.shared.hex("#A1A5A6")
        view.backgroundColor = Color.shared.hex("#A1A5A6")
        imagesCollection.backgroundColor = Color.shared.hex("#A1A5A6")
    }
    
    //кнопка для окончательного добавления сайта / изменения сайта
    @IBAction func addSiteAction(_ sender: Any) {
        
        //добавление сайта
        if self.changingTheSite == false {
            
            try! MyRealm.realm.write() {
                
                let newSite = SiteForTable()
                newSite.name = nameForNewSite
                newSite.currency = currencyForNewSite
                newSite.image = imageForNewSite
                newSite.typeOfEarningText = typeOfEarningText
                newSite.usePercentage = usePercentage
                MyRealm.realm.add(newSite)
            }
            
            self.dismiss(animated: true, completion: nil)
            delegate?.reloadData()
            
            //изменение сайта
        } else {
            
            try! MyRealm.realm.write {
                
                MyRealm.realm.objects(SiteForTable.self)[indexOfSiteInRealm].currency = currencyForNewSite
                MyRealm.realm.objects(SiteForTable.self)[indexOfSiteInRealm].image = imageForNewSite
                MyRealm.realm.objects(SiteForTable.self)[indexOfSiteInRealm].name = nameForNewSite
                MyRealm.realm.objects(SiteForTable.self)[indexOfSiteInRealm].usePercentage = usePercentage
                MyRealm.realm.objects(SiteForTable.self)[indexOfSiteInRealm].typeOfEarningText = typeOfEarningText
            }
            
            self.dismiss(animated: true, completion: nil)
            delegate?.reloadData()
        }
    }
    
    //заполнение переменных данными сайта который меняем
    func valuesForVariables() {
        
        if self.changingTheSite == true {
            
            self.nameForNewSite = self.addSiteItems[0].textFieldDefaultText
            self.typeOfEarningText = self.addSiteItems[1].name
            self.imageForNewSite = self.addSiteItems[2].imageName
            self.usePercentage = self.addSiteItems[0].usePercentage
            self.currencyForNewSite = MyRealm.realm.objects(SiteForTable.self)[indexOfSiteInRealm].currency
        } else { return }
        
    }
    
    //название кнопки save/add
    func addChangeButtonName() {
        
        if self.changingTheSite == true {
            
            addButton.setTitle("Сохранить", for: .normal)
            
        } else { addButton.setTitle("Добавить", for: .normal) }
        
    }
    
    //кнопка отмены
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //проверка на заполненность всех полей
    func validationCheck() {
        
        if self.changingTheSite == false {
            
            if nameValidation && !imageForNewSite.isEmpty && currencySelected && typeEditing{
                addButton.isEnabled = true
            } else { addButton.isEnabled = false }
            
        }
        
    }
    
    //таргет для текстфилда на проверку введено ли имя сайта
    @objc func checkNameEntered(sender: UITextField) {
        
        self.currencyPicker.isHidden = true
        self.imagesCollection.isHidden = true
        
        //не дает поставить пробел в начале
        if sender.text?.count == 1 {
            
            if sender.text == " " {
                sender.text = ""
            }
        }
        
        //если путой кнопка неактивна
        if sender.text!.isEmpty {
            self.nameValidation = false
            self.warningLabel.isHidden = true
            self.validationCheck()
        }
        
        //если добавляем а не меняем сайт и есть уже сайт с таким именен подсвечивает красным и кнопка неактивна
        else if self.changingTheSite == false && MyRealm.realm.objects(SiteForTable.self).filter("name LIKE[c] '\(sender.text!.trimmingCharacters(in: .whitespacesAndNewlines))'").count != 0 {
            sender.textColor = .red
            self.warningLabel.isHidden = false
            self.nameValidation = false
            self.validationCheck()
        }
        
        //кнопка активна
        else { nameValidation = true
            sender.textColor = Color.shared.hex("#D9D9D9")
            self.nameForNewSite = sender.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            self.addSiteItems[0].textFieldDefaultText = sender.text!
            self.warningLabel.isHidden = true
            self.validationCheck()
        }
        
    }
    
    //показ/скрытие пикера и имейдж коллекции
    func pickerAndImageCollection(checkForSelect: Bool, indexPath: IndexPath, cell: AddSiteCell?) {
        
        if checkForSelect {
            
            switch indexPath.row {
            case 0:
                
                self.imagesCollection.isHidden = true
                self.currencyPicker.isHidden = true
                
            case 1:
                
                self.imagesCollection.isHidden = true
                self.currencyPicker.isHidden = true
                guard let typeOfEarningVC = (storyboard?.instantiateViewController(identifier: "typeOfEarningVC")) as? TypeOfEarningViewController else {return}
                typeOfEarningVC.delegate = self
                presentDetail(typeOfEarningVC)
                
            case 2:
                
                self.imagesCollection.isHidden = false
                self.currencyPicker.isHidden = true
                self.currencyPickerHeightConstraint.constant = 0
                
            case 3:
                
                self.currencyPicker.isHidden = false
                addSiteItems[3].name = currency.first!
                cell!.nameLabel.textColor = Color.shared.hex("#D9D9D9")
                self.addSiteTable.reloadData()
                currencySelected = true
                currencyForNewSite = .`$`
                validationCheck()
                self.currencyPickerHeightConstraint.constant = 100
                self.view.layoutIfNeeded()
                
            default: return
            }
        } else {
            switch indexPath.row {
            case 0: return
                
            case 2: self.imagesCollection.isHidden = true
                
            case 3:
                
                self.currencyPicker.isHidden = true
                self.currencyPickerHeightConstraint.constant = 0
                
            default: return
            }
        }
        
    }
    
}

//делегат датасорс таблицы
extension AddSiteViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        addSiteItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addSiteCell") as! AddSiteCell
        
        if self.changingTheSite == true && indexPath.row == 1 {cell.nameLabel.textColor = Color.shared.hex("#D9D9D9")}
        else if self.changingTheSite == true && indexPath.row == 3 {cell.nameLabel.textColor = Color.shared.hex("#D9D9D9")}
        else if self.typeEditing == true && indexPath.row == 1 {cell.nameLabel.textColor = Color.shared.hex("#D9D9D9")}
        cell.configureAddSiteCell(data: addSiteItems[indexPath.row])
        cell.siteNameTextField.addTarget(self, action: #selector(checkNameEntered), for: .editingChanged)
        cell.backgroundColor = Color.shared.hex("#353D40")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! AddSiteCell
        pickerAndImageCollection(checkForSelect: true, indexPath: indexPath, cell: cell)
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        pickerAndImageCollection(checkForSelect: false, indexPath: indexPath, cell: nil)
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}

//делегат датасорс пикера
extension AddSiteViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currency.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.currency[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currencySelected = true
        addSiteItems[3].name = currency[row]
        currencyForNewSite = Currency.init(rawValue: currency[row])!
        validationCheck()
        self.addSiteTable.reloadData()
    }
    
}

extension AddSiteViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! ImageCell
        cell.configureImageCell(image: images[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        imagesCollection.isHidden = true
        imageForNewSite = images[indexPath.row]
        addSiteItems[2].imageName = images[indexPath.row]
        addSiteItems[2].imageisHiden = false
        addSiteItems[2].name = ""
        self.addSiteTable.reloadData()
        validationCheck()
    }
    
}

extension AddSiteViewController: TypeOfEarningDelegate {
    func saveTypeOfEarning(usePercentage: Bool, name: String) {
        self.usePercentage = usePercentage
        self.addSiteItems[1].name = name
        self.typeOfEarningText = name
        self.addSiteTable.reloadData()
        self.typeEditing = true
        self.validationCheck()
    }
}

extension AddSiteViewController {
    
    func presentDetail(_ viewControllerToPresent: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeInEaseOut)
        self.view.window!.layer.add(transition, forKey: kCATransition)
        
        present(viewControllerToPresent, animated: false)
    }
}
