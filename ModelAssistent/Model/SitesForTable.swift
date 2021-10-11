import Foundation
import RealmSwift

class SiteForTable: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var image = ""
    @objc dynamic var siteCurrency = ""
    @objc dynamic var usePercentage: Bool = false
    @objc dynamic var typeOfEarningText = ""
    var currency: Currency {
        get{ return Currency(rawValue: siteCurrency)! }
        set{ siteCurrency = newValue.rawValue }
    }
    
    static func createDeafaultSites() {
        
        try! MyRealm.realm.write() {
            
            let liveJasmin = SiteForTable()
            liveJasmin.name = "LiveJasmin"
            liveJasmin.currency = .`$`
            liveJasmin.image = "image10"
            liveJasmin.usePercentage = true
            liveJasmin.typeOfEarningText = "Для расчета дохода использовать процент"
            MyRealm.realm.add(liveJasmin)
            
            let chaturbate = SiteForTable()
            chaturbate.name = "Chaturbate"
            chaturbate.currency = .tk
            chaturbate.image = "image2"
            chaturbate.usePercentage = true
            chaturbate.typeOfEarningText = "Для расчета дохода использовать процент"
            MyRealm.realm.add(chaturbate)
            
            let stripchat = SiteForTable()
            stripchat.name = "Stripchat"
            stripchat.currency = .tk
            stripchat.image = "image20"
            stripchat.usePercentage = true
            stripchat.typeOfEarningText = "Для расчета дохода использовать процент"
            MyRealm.realm.add(stripchat)
            
            let streamate = SiteForTable()
            streamate.name = "Streamate"
            streamate.currency = .`$`
            streamate.image = "image13"
            streamate.usePercentage = true
            streamate.typeOfEarningText = "Для расчета дохода использовать процент"
            MyRealm.realm.add(streamate)
            
            let eurolive = SiteForTable()
            eurolive.name = "Eurolive"
            eurolive.currency = .€
            eurolive.image = "image5"
            eurolive.usePercentage = true
            eurolive.typeOfEarningText = "Для расчета дохода использовать процент"
            MyRealm.realm.add(eurolive)
            
        }
    }
    
    static var currentSites: Results<SiteForTable> = {
        return MyRealm.realm.objects(SiteForTable.self)
    }()
}

enum Currency: String {
    
    case tk
    case `$`
    case €
    
}


