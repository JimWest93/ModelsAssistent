import Foundation
import RealmSwift

class ModelPercentage: Object {
    
    @objc dynamic var percentage = 0
    
    static func defaultModelPercentage() {
        
        try! MyRealm.realm.write() {
            
            let defaultPercentage = ModelPercentage()
            defaultPercentage.percentage = 100
            MyRealm.realm.add(defaultPercentage)
        
        }
    }
    
    static let percentage: Int = {
        guard let percentage = MyRealm.realm.objects(ModelPercentage.self).first?.percentage else {return 100}
        return percentage
    }()
}
