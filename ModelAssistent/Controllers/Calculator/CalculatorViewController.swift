import UIKit

class CalculatorViewController: UIViewController {
    
    @IBOutlet weak var currencySC: UISegmentedControl!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var myValueTF: UITextField!
    @IBOutlet weak var tokensLabel: UILabel!
    @IBOutlet weak var usdLabel: UILabel!
    @IBOutlet weak var euroLabel: UILabel!
    @IBOutlet weak var rubLabel: UILabel!
    @IBOutlet weak var percentageLabel: UILabel!
    
    @IBOutlet var currencyViews: [UIView]!
    @IBOutlet weak var tokensView: UIView!
    @IBOutlet weak var usdView: UIView!
    @IBOutlet weak var euroView: UIView!
    @IBOutlet weak var rubView: UIView!
    
    @IBOutlet weak var usdRateLabel: UILabel!
    @IBOutlet weak var euroRateLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    let currencyArray = ["Tokens", "USD", "EUR", "RUB"]
    
    var usdRate = 0.0
    var euroRate = 0.0
    
    let loader = RatesLoader()
    let settings = SettingsViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        
        myValueTF.addTarget(self, action: #selector(convertation), for: .allEditingEvents)
        currencyViewsSetup()
        currencySCsetup()
        
        loader.delegate = self
        loader.ratesLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(randomTap))
        self.view.addGestureRecognizer(tap)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ratesLabelsSetup(rates: RatesRealm.ratesForCalculator())
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        percentageLabel.text = String(MyRealm.realm.objects(ModelPercentage.self).first?.percentage ?? 100)
    }
    
    @objc func randomTap() {
        self.view.endEditing(true)
    }
    
    func currencySCsetup() {
        
        self.currencySC.removeAllSegments()
        
        for (index, currency) in currencyArray.enumerated() {
            currencySC.insertSegment(withTitle: currency, at: index, animated: false)
        }
        
        currencySC.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Color.shared.hex("#F2B138")], for: .selected)
        currencySC.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Color.shared.hex("#A1A5A6")], for: .normal)
        currencySC.addTarget(self, action: #selector(hideCurrencyViews), for: .valueChanged)
        currencySC.addTarget(self, action: #selector(currencySelection), for: .valueChanged)
        currencySC.addTarget(self, action: #selector(convertation), for: .valueChanged)
        currencySC.selectedSegmentIndex = 0
        convertation()
        currencySelection()
        hideCurrencyViews()
    }
    
    @objc func convertation() {
        
        myValueTF.text = myValueTF.text?.replacingOccurrences(of: ",", with: ".", options: .literal, range: nil)
        
        let myValue: Double = {
            
            var myValue = 0.0
            
            if !myValueTF.text!.isEmpty {
                if Double(myValueTF.text!) != nil {
                    myValue = Double(myValueTF.text!)!
                    myValueTF.textColor = Color.shared.hex("#353D40")
                } else { myValue = 0.0
                    myValueTF.textColor = .systemRed
                }
            } else { myValue = 0.0
                myValueTF.textColor = Color.shared.hex("#353D40")
            }
            
            return myValue
        }()
        
        let exchageRate = Double(ExchangeRate.exchangeRate)
        let percentage = MyRealm.realm.objects(ModelPercentage.self).first?.percentage ?? 100
        
        switch currencySC.titleForSegment(at: currencySC.selectedSegmentIndex) {
            
        case "Tokens":
            
            usdLabel.text = String(format: "%.2f", myValue / 20.0 / 100 * Double(percentage))
            euroLabel.text = String(format: "%.2f", Double(usdLabel.text!)! * exchageRate)
            rubLabel.text = String(format: "%.2f", Double(usdLabel.text!)! * usdRate)
            
        case "USD":
            
            tokensLabel.text = String(format: "%.2f", myValue * 20.0 * 100.0 / Double(percentage))
            euroLabel.text = String(format: "%.2f", myValue / exchageRate)
            rubLabel.text = String(format: "%.2f", myValue * usdRate)
            
        case "EUR":
            
            usdLabel.text = String(format: "%.2f", myValue * exchageRate )
            tokensLabel.text = String(format: "%.2f", Double(usdLabel.text!)! * 20.0 * 100.0 / Double(percentage))
            rubLabel.text = String(format: "%.2f", myValue * euroRate)
            
        case "RUB":
            
            usdLabel.text = String(format: "%.2f", myValue / usdRate)
            euroLabel.text = String(format: "%.2f", myValue / euroRate)
            tokensLabel.text = String(format: "%.2f", Double(usdLabel.text!)! * 20.0 * 100.0 / Double(percentage))
            
        default: break
        }
    }
    
    @objc func currencySelection() {
        switch currencySC.titleForSegment(at: currencySC.selectedSegmentIndex) {
        case "Tokens": currencyLabel.text = "tk"
        case "USD": currencyLabel.text = "$"
        case "EUR": currencyLabel.text = "€"
        case "RUB": currencyLabel.text = "₽"
        default: break
        }
    }
    
    @objc func hideCurrencyViews() {
        
        switch currencySC.titleForSegment(at: currencySC.selectedSegmentIndex) {
        case "Tokens":
            
            tokensView.isHidden = true
            usdView.isHidden = false
            euroView.isHidden = false
            rubView.isHidden = false
            
        case "USD":
            
            tokensView.isHidden = false
            usdView.isHidden = true
            euroView.isHidden = false
            rubView.isHidden = false
            
        case "EUR":
            
            tokensView.isHidden = false
            usdView.isHidden = false
            euroView.isHidden = true
            rubView.isHidden = false
            
        case "RUB":
            
            tokensView.isHidden = false
            usdView.isHidden = false
            euroView.isHidden = false
            rubView.isHidden = true
            
        default: break
        }
        
    }
    
    func currencyViewsSetup() {
        
        for view in currencyViews {
            view.layer.cornerRadius = 10
            view.layer.shadowColor = Color.shared.hex("#353D40").cgColor
            view.layer.shadowOffset = CGSize(width: 0, height: 2)
            view.layer.shadowRadius = 3
            view.layer.shadowOpacity = 1
            view.layer.masksToBounds = false
        }
        
    }
    
    func ratesLabelsSetup(rates: [String : Double]) {
        
        self.euroRateLabel.text = String(rates["EUR"] ?? 0.0)
        self.usdRateLabel.text = String(rates["USD"] ?? 0.0)
        self.dateLabel.text = RatesRealm.ratesDate()
    }
    
}


extension CalculatorViewController: RatesDelegate {
    func ratesUpdate(rates: [String : Double]) {
        self.usdRate = rates["USD"] ?? 0.0
        self.euroRate = rates["EUR"] ?? 0.0
        
        self.euroRateLabel.text = String(rates["EUR"] ?? 0.0)
        self.usdRateLabel.text = String(rates["USD"] ?? 0.0)
    }
}
