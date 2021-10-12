import Foundation
import RealmSwift

class MyRealm {
    
    static var realm: Realm = {
        
        let realm = try! Realm()
    
        return realm
        
    }()

}
