import Foundation

struct AddingSiteItem {
    
    var nameLabelisHiden: Bool
    var name: String
    var textFieldisHiden: Bool
    var imageisHiden: Bool
    var imageName: String
    var textFieldDefaultText: String
    var arrowImageisHidden: Bool
    var usePercentage: Bool
    
}

class ItemsToAddSite {
    
    static func itemsForSiteAdding () -> [AddingSiteItem] {
        
        return [ AddingSiteItem(nameLabelisHiden: false, name: "Имя сайта:", textFieldisHiden: false, imageisHiden: true, imageName: "", textFieldDefaultText: "", arrowImageisHidden: true, usePercentage: false),
                 AddingSiteItem(nameLabelisHiden: false, name: "Расчет дохода", textFieldisHiden: true, imageisHiden: true, imageName: "", textFieldDefaultText: "", arrowImageisHidden: false, usePercentage: false),
                 AddingSiteItem(nameLabelisHiden: false, name: "Значок сайта", textFieldisHiden: true, imageisHiden: true, imageName: "", textFieldDefaultText: "", arrowImageisHidden: true, usePercentage: false),
                 AddingSiteItem(nameLabelisHiden: false, name: "Валюта", textFieldisHiden: true, imageisHiden: true, imageName: "", textFieldDefaultText: "", arrowImageisHidden: true, usePercentage: false)
        ]
    }
}

class ItemsToChangeSite {
    
    static func itemsToChangeSite (data: SiteForTable) -> [AddingSiteItem] {
        
        return [ AddingSiteItem(nameLabelisHiden: true, name: "Имя сайта:", textFieldisHiden: false, imageisHiden: true, imageName: "", textFieldDefaultText: data.name, arrowImageisHidden: true, usePercentage: data.usePercentage),
                 AddingSiteItem(nameLabelisHiden: false, name: data.typeOfEarningText, textFieldisHiden: true, imageisHiden: true, imageName: "", textFieldDefaultText: "", arrowImageisHidden: false, usePercentage: data.usePercentage),
                 AddingSiteItem(nameLabelisHiden: false, name: "", textFieldisHiden: true, imageisHiden: false, imageName: data.image, textFieldDefaultText: "", arrowImageisHidden: true, usePercentage: data.usePercentage),
                 AddingSiteItem(nameLabelisHiden: false, name: (data.currency.rawValue), textFieldisHiden: true, imageisHiden: true, imageName: "", textFieldDefaultText: "", arrowImageisHidden: true, usePercentage: data.usePercentage)
        ]
        
    }

}
