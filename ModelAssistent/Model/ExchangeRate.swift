import Foundation
import RealmSwift

class ExchangeRate: Object {
    
    @objc dynamic var exchangeRate = 0.0
    
    static func defaultExchangeRate() {
        
        try! MyRealm.realm.write() {
            
            let defaultExchangeRate = ExchangeRate()
            defaultExchangeRate.exchangeRate = 1.19
            MyRealm.realm.add(defaultExchangeRate)
        
        }
    }
    
    static let exchangeRate: Double = {
        guard let exchangeRate = MyRealm.realm.objects(ExchangeRate.self).first?.exchangeRate else {return 1.19}
        return exchangeRate
    }()
}
