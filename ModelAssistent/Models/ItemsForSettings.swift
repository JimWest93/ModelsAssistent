import Foundation

struct SettingItem {
    
    var name: String
    var infoLableIsHidden: Bool
    var infoLableText: String
    
}

class ItemsForSettings {
    
    static func itemsForSettings() -> [SettingItem] {
        
        return [ SettingItem(name: "Настройка сайтов", infoLableIsHidden: true, infoLableText: ""),
                 SettingItem(name: "Процент по умолчанию", infoLableIsHidden: false, infoLableText:
                                "\(ModelPercentage.modelPercentage)%"),
                 SettingItem(name: "Кросс-курс евро к доллару", infoLableIsHidden: false, infoLableText: "\(ExchangeRate.exchangeRate)")
                 
        ]
        
    }
    
}
