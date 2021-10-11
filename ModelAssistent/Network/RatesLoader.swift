import Foundation
import Alamofire

protocol RatesDelegate {
    func ratesUpdate(rates: [String: Double])
}

class RatesLoader {
    
    var delegate: RatesDelegate?
    
    func ratesLoad() {
        
        let ratesURL = "https://www.cbr-xml-daily.ru/daily_json.js"
        
        AF.request(ratesURL)
            
            .validate()
            .responseDecodable(of: Rates.self, queue: .main) { (response) in
                
                switch response.result {
                case .success:
                    print("Successful")
                case .failure (let error):
                    print(error.localizedDescription)
                }
                
                guard let data = response.value
                else {return}
                
                if MyRealm.realm.objects(RatesRealm.self).isEmpty {
                    
                    for (_, value) in data.valute {
                        
                        try! MyRealm.realm.write {
                            
                            let rate = RatesRealm()
                            rate.name = value.charCode
                            rate.value = value.value
                            rate.date = data.date
                            
                            MyRealm.realm.add(rate)
                            
                        }
                    }
                    
                    self.delegate?.ratesUpdate(rates: RatesRealm.ratesForCalculator())
                    
                } else {
                    
                    try! MyRealm.realm.write {
                        
                        MyRealm.realm.delete(MyRealm.realm.objects(RatesRealm.self))
                        
                        for (_, value) in data.valute {
                            
                            let rate = RatesRealm()
                            rate.name = value.charCode
                            rate.value = value.value
                            rate.date = data.date
                            
                            MyRealm.realm.add(rate)
                            
                        }
                    }
                    
                    self.delegate?.ratesUpdate(rates: RatesRealm.ratesForCalculator())
                    
            }
        }
    }
}
