import Foundation
import RealmSwift

class DateForCallendar: Object {
    
    @objc dynamic var defaultDate = Date()
    
    static func defaultDateForCallendar() -> Date {
        
        if MyRealm.realm.objects(DateForCallendar.self).isEmpty {
            
            try! MyRealm.realm.write() {
                
                let defaultDate = DateForCallendar()
                defaultDate.defaultDate = Date()
                MyRealm.realm.add(defaultDate)
                
            }
            
            guard let date = MyRealm.realm.objects(DateForCallendar.self).first?.defaultDate else { return Date() }
                
            return date
            
        }
        
        else {
            
            return MyRealm.realm.objects(DateForCallendar.self).first!.defaultDate
            
        }
        
    }
}
