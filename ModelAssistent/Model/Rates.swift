import Foundation
import RealmSwift

class RatesRealm: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var value = 0.0
    @objc dynamic var date = ""
    
    static func ratesForCalculator() -> [String: Double] {
        
        var rates: [String : Double] = [:]
        
        if MyRealm.realm.objects(RatesRealm.self).isEmpty {
            
            return [:]
            
        } else {
            
            for rate in MyRealm.realm.objects(RatesRealm.self) {
                
                rates[rate.name] = rate.value
                
            }
            
        }
        
        return rates
    }
    
    static func ratesDate() -> String {
        
        let dateFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.locale = Locale(identifier: "ru_RU")
            dateFormatter.dateFormat = "dd.MM.yyyy"
            return dateFormatter
        }()
        
        return dateFormatter.string(from: Date())
        
    }
}


struct Rates: Codable {
    
    var date: String = ""
    
    var valute: [String: Valute] = ["": Valute()]

    enum CodingKeys: String, CodingKey {
        case date = "Date"
        case valute = "Valute"
    }
}

struct Valute: Codable {
    
    var charCode: String = ""
    var value: Double = 0.0

    enum CodingKeys: String, CodingKey {
        
        case charCode = "CharCode"
        case value = "Value"

    }
}
