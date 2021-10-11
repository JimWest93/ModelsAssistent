import Foundation
import SwiftHEXColors

final class Color {
    
    static var shared: Color = {
        let instance = Color()
        return instance
    }()
    
    func hex(_ hexString: String) -> UIColor {
        
        return UIColor(hexString: hexString)!
        
    }
    
    private init() {
        
    }
    
}
