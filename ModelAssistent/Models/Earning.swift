import Foundation
import RealmSwift

class Earning: Object {
    
    
    @objc dynamic var date = ""
    @objc dynamic var dateInDateFormat = Date()
    @objc dynamic var siteName = ""
    @objc dynamic var totalEarningInDollars = 0.0
    @objc dynamic var earningPerHour = 0.0
    @objc dynamic var earningInSiteCurrency = 0.0
    @objc dynamic var hoursOnline = 0.0
    @objc dynamic var percentage = 0
    @objc dynamic var currency = ""
    @objc dynamic var earningWithoutPercentage = 0.0
    @objc dynamic var usePercentage = false
    
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "dd MM YYYY"
        return dateFormatter
    }()
    
    
    convenience init(currency: String, hoursOnline: Double?, siteName: String, date: Date, percentage: Int, earningInSiteCurrency: Double?, conversion: Double, usePercentage: Bool) {
        self.init()
        self.usePercentage = usePercentage
        self.dateInDateFormat = date
        dateFormatter.dateFormat = "dd MM YYYY"
        self.date = dateFormatter.string(from: date)
        self.siteName = siteName
        self.hoursOnline = hoursOnline ?? 1
        self.percentage = percentage
        self.currency = currency
        
        if usePercentage == true {
            
            self.earningInSiteCurrency = (earningInSiteCurrency ?? 0) / 100 * Double(percentage)
            
        } else { self.earningInSiteCurrency = (earningInSiteCurrency ?? 0) }
        
        self.earningWithoutPercentage = earningInSiteCurrency ?? 0
        
        switch currency {
        
        case "$":
            self.totalEarningInDollars = self.earningInSiteCurrency
            self.earningPerHour = self.totalEarningInDollars / (hoursOnline ?? 1)
            
        case "tk":
            self.totalEarningInDollars = self.earningInSiteCurrency * 0.05
            self.earningPerHour = self.totalEarningInDollars / (hoursOnline ?? 1)
            
        case "???":
            self.totalEarningInDollars = self.earningInSiteCurrency * conversion
            self.earningPerHour = self.totalEarningInDollars / (hoursOnline ?? 1)
            
        default: break
        }
        
    }
    
    
    //MARK: ??????????????
    
    //MARK: ???????????????????? ???? ????????
    
    //?????? ?????????????? ???? ???????? ????????
    static func oneDayObjects(date: String) -> Results<Earning> {
        return MyRealm.realm.objects(Earning.self).filter("date = '\(date)'")
    }
    
    //???????????? ?????????????????? ???? ????????
    static func totalDaylyEarning(date: String) -> Double {
        var totalEarning = 0.0
        for earning in oneDayObjects(date: date) {
            totalEarning += earning.totalEarningInDollars
        }
        return totalEarning
    }
    
    //?????????????????? ???? ???????? ?? ??????
    static func earningsPerHourPerDay(date: String) -> Double {
        var totalEarningPerHour = 0.0
        for earning in oneDayObjects(date: date) {
            totalEarningPerHour += earning.earningPerHour
        }
        return totalEarningPerHour
    }
    
    //?????????????? ???????? ???? ????????
    static func topSiteOfTheDay(date: String) -> String {
        let earningObjects = oneDayObjects(date: date)
        var siteName = ""
        var maxEarningSite = earningObjects.first?.totalEarningInDollars ?? 0
        for earning in earningObjects {
            if earning.totalEarningInDollars >= maxEarningSite {
                maxEarningSite = earning.totalEarningInDollars
                siteName = earning.siteName
            }
        }
        return siteName
    }
    
    //???????? ?????????????? ???? ????????
    static func hoursOnlineOfTheDay(date: String) -> Double {
        return oneDayObjects(date: date).first?.hoursOnline ?? 0
    }
    
    //MARK: ???????????????????? ???? ?????? ??????????
    
    //?????????? ?????????????????? ???? ?????? ??????????
    static func allTimeEarning() -> Double {
        
        var totalEarning = 0.0
        
        for earning in MyRealm.realm.objects(Earning.self) {
            
            totalEarning += earning.totalEarningInDollars
            
        }
        
        return totalEarning
        
    }
    
    //???????????????????? ???????? ?? ?????????? ???? ?????? ??????????
    static func totalDaysAndHours() -> (days: Int, hours: Double) {
        
        var totalDaysAndHours: (days: Int, hours: Double) = (0, 0)
        var date = ""
        
        for earning in MyRealm.realm.objects(Earning.self).sorted(byKeyPath: "date") {
            
            if date != earning.date {
                totalDaysAndHours.hours += earning.hoursOnline
                totalDaysAndHours.days += 1
                date = earning.date
            }
        }
        
        return totalDaysAndHours
        
    }
    
    //?????????????? ?????????????????? ?? ?????? ???? ?????? ??????????
    static func averageEarningPerHourAllTime() -> Double {
        
        return Earning.allTimeEarning() / Earning.totalDaysAndHours().hours
        
    }
    
    //???????????? ?????????? ???? ?????? ??????????
    static func bestMonthAllTime() -> (topMonthName: String, topMonthEarning: Double) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "LLLL yyyy"
        
        var monthEarningDict: [String: Double] = ["" : 0.0]
        
        for earning in MyRealm.realm.objects(Earning.self).sorted(byKeyPath: "dateInDateFormat") {
            
            if monthEarningDict[dateFormatter.string(from: earning.dateInDateFormat)] != nil {
                
                monthEarningDict[dateFormatter.string(from: earning.dateInDateFormat)]! += earning.totalEarningInDollars
                
            } else { monthEarningDict[dateFormatter.string(from: earning.dateInDateFormat)] = earning.totalEarningInDollars }
            
        }
        
        let topSiteDict = monthEarningDict.max {a, b in a.value < b.value }
        let topMonthName = topSiteDict?.key
        let topMonthEarning = topSiteDict?.value
        
        return (topMonthName ?? "", topMonthEarning ?? 0)
        
    }
    
    //???????????? ???????? ???????????? ???? ?????? ??????????
    static func bestDayAllTime() -> (name: String, earning: Double) {
        
        var bestDayName = ""
        var bestDayEarning = 0.0
        
        let daysData = Earning.daysForCharts(itsForMonth: false, month: "")
        
        if let max = daysData.earning.max() {
            
            let index = daysData.earning.firstIndex(of: max)
            bestDayName = daysData.day[index!]
            bestDayEarning = daysData.earning[index!]
            
        }
        
        return (bestDayName, bestDayEarning)
    }
    
    //?????? ???????? ???? ?????? ??????????
    static func bestSiteAllTime() -> (topSiteName: String, topSiteEarning: Double) {
        
        var siteEarningDict: [String: Double] = ["" : 0.0]
        
        for earning in MyRealm.realm.objects(Earning.self).sorted(byKeyPath: "siteName") {
            
            if siteEarningDict[earning.siteName] != nil {
                
                siteEarningDict[earning.siteName]! += earning.totalEarningInDollars
                
            } else { siteEarningDict[earning.siteName] = earning.totalEarningInDollars }
            
        }
        
        let topSiteDict = siteEarningDict.max { a, b in a.value < b.value }
        let topSiteName = topSiteDict?.key
        let topSiteEarning = topSiteDict?.value
        
        return (topSiteName ?? "", topSiteEarning ?? 0)
    }
    
    //?????? ???????? ?????? ?????????????? ????????????????
    static func years() -> [String] {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "YYYY"
        
        let firstDate = MyRealm.realm.objects(Earning.self).sorted(byKeyPath: "dateInDateFormat").first?.dateInDateFormat
        var firstYear = dateFormatter.string(from: firstDate ?? Date())
        
        var yearArray: [String] = []
        yearArray.append(firstYear)
        
        for earning in MyRealm.realm.objects(Earning.self).sorted(byKeyPath: "dateInDateFormat") {
            
            if dateFormatter.string(from: earning.dateInDateFormat) != firstYear {
                firstYear = dateFormatter.string(from: earning.dateInDateFormat)
                yearArray.append(firstYear)
            }
            
        }
        
        return yearArray
        
    }
    
    //MARK: ???????????????????? ???? ??????????????
    
    //???????????? ???????? ?????????????? ?? ????????????????????
    static func allMonthWithEarning() -> [String] {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "LLLL yy"
        
        let firstDate = MyRealm.realm.objects(Earning.self).sorted(byKeyPath: "dateInDateFormat").first?.dateInDateFormat
        var firstMonth = dateFormatter.string(from: firstDate ?? Date()).firstUppercased
        
        var monthArray: [String] = []
        monthArray.append(firstMonth)
        
        for earning in MyRealm.realm.objects(Earning.self).sorted(byKeyPath: "dateInDateFormat") {
            
            if dateFormatter.string(from: earning.dateInDateFormat).firstUppercased != firstMonth {
                firstMonth = dateFormatter.string(from: earning.dateInDateFormat).firstUppercased
                monthArray.append(firstMonth)
            }
            
        }
        
        return monthArray
    }
    
    //?????????? ?????????????????? ???? ??????????
    static func totalEarningMonth(month: String) -> Double {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "LLLL yy"
        
        var totalEarning = 0.0
        
        for earning in MyRealm.realm.objects(Earning.self).sorted(byKeyPath: "dateInDateFormat") {
            
            if dateFormatter.string(from: earning.dateInDateFormat).firstUppercased == month {
                
                totalEarning += earning.totalEarningInDollars
                
            }
            
        }
        
        return totalEarning
        
    }
    
    //?????????????? ?????????????????? ?? ?????? ???? ??????????
    static func averageEarningPerHourMonth(month: String) -> Double {
        
        return Earning.totalEarningMonth(month: month) / Earning.totalDaysAndHoursMonth(month: month).hours
        
    }
    
    //?????????? ???????????????????? ???????? ?? ?????????? ?? ????????????
    static func totalDaysAndHoursMonth(month: String) -> (days: Int, hours: Double) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "LLLL yy"
        
        var totalDaysAndHoursMonth: (days: Int, hours: Double) = (0, 0)
        
        var date = ""
        
        for earning in MyRealm.realm.objects(Earning.self).sorted(byKeyPath: "date") {
            
            if dateFormatter.string(from: earning.dateInDateFormat).firstUppercased == month {
                
                if date != earning.date {
                    totalDaysAndHoursMonth.days += 1
                    totalDaysAndHoursMonth.hours += earning.hoursOnline
                    date = earning.date
                }
            }
        }
        
        return totalDaysAndHoursMonth
    }
    
    //?????? ???????? ????????????
    static func topSiteMonth(month: String) -> (topSiteName: String, topSiteEarning: Double) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "LLLL yy"
        
        var siteEarningDict: [String: Double] = ["" : 0.0]
        
        for earning in MyRealm.realm.objects(Earning.self).sorted(byKeyPath: "dateInDateFormat") {
            
            if dateFormatter.string(from: earning.dateInDateFormat).firstUppercased == month {
                
                if siteEarningDict[earning.siteName] != nil {
                    
                    siteEarningDict[earning.siteName]! += earning.totalEarningInDollars
                    
                } else { siteEarningDict[earning.siteName] = earning.totalEarningInDollars }
                
            }
            
        }
        
        let topSiteDict = siteEarningDict.max { a, b in a.value < b.value }
        let topSiteName = topSiteDict?.key
        let topSiteEarning = topSiteDict?.value
        
        return (topSiteName ?? "", topSiteEarning ?? 0)
    }
    
    //???????????? ???????? ???????????? ?? ????????????
    static func topDayForLabelMonth(month: String) -> (name: String, earning: Double) {
        
        var bestDayName = ""
        var bestDayEarning = 0.0
        
        let daysData = daysForCharts(itsForMonth: true, month: month)
        
        if let max = daysData.earning.max() {
            
            let index = daysData.earning.firstIndex(of: max)
            bestDayName = daysData.day[index!]
            bestDayEarning = daysData.earning[index!]
        }
        
        return (bestDayName, bestDayEarning)
    }
    
    
    //MARK: ??????????????
    
    //???????????? ?????? ?????????????? ??????????????
    static func bestMonthAllTimeForCharts(year: String) -> (month: [String], earning: [Double]) {
        
        let dateFormatterMonth = DateFormatter()
        dateFormatterMonth.timeZone = TimeZone.current
        dateFormatterMonth.locale = Locale(identifier: "ru_RU")
        dateFormatterMonth.dateFormat = "LLL"
        
        let dateFormatterYear = DateFormatter()
        dateFormatterYear.timeZone = TimeZone.current
        dateFormatterYear.dateFormat = "YYYY"
        
        
        var monthArray: [String] = []
        var valueArray: [Double] = []
        
        for earning in MyRealm.realm.objects(Earning.self).sorted(byKeyPath: "dateInDateFormat") {
            
            if dateFormatterYear.string(from: earning.dateInDateFormat) == year {
                
                if monthArray.contains(dateFormatterMonth.string(from: earning.dateInDateFormat).firstUppercased) == false {
                    
                    monthArray.append(dateFormatterMonth.string(from: earning.dateInDateFormat).firstUppercased)
                    valueArray.append((earning.totalEarningInDollars * 10).rounded() / 10)
                    
                } else { valueArray[monthArray.firstIndex(of: dateFormatterMonth.string(from: earning.dateInDateFormat).firstUppercased)!] += (earning.totalEarningInDollars * 10).rounded() / 10 }
                
            }
            
        }
        
        return (monthArray, valueArray)
    }
    
    //???????????? ???? ???????? ???? ?????? ?????????? ?????? ???? ??????????
    static func daysForCharts(itsForMonth: Bool, month: String) -> (day: [String], earning: [Double]) {
        
        let dateFormatterMonth = DateFormatter()
        dateFormatterMonth.timeZone = TimeZone.current
        dateFormatterMonth.locale = Locale(identifier: "ru_RU")
        dateFormatterMonth.dateFormat = "LLLL yy"
        
        let dateFormatterDay = DateFormatter()
        dateFormatterDay.timeZone = TimeZone.current
        dateFormatterDay.locale = Locale(identifier: "ru_RU")
        dateFormatterDay.dateFormat = "EEEE"
        
        var dayArray: [String] = []
        var valueArray: [Double] = []
        var newArrayOfDays: [String] = []
        var newValues: [Double] = []
        let sortedDays: [String] = ["??????????????????????", "??????????????", "??????????", "??????????????", "??????????????", "??????????????", "??????????????????????"]
        
        if !itsForMonth {
            
            for earning in MyRealm.realm.objects(Earning.self).sorted(byKeyPath: "dateInDateFormat") {
                
                if dayArray.contains(dateFormatterDay.string(from: earning.dateInDateFormat)) == false {
                    
                    dayArray.append(dateFormatterDay.string(from: earning.dateInDateFormat))
                    valueArray.append((earning.totalEarningInDollars.rounded()))
                    
                } else { valueArray[dayArray.firstIndex(of: dateFormatterDay.string(from: earning.dateInDateFormat))!] += earning.totalEarningInDollars.rounded() }
                
            }
        } else {
            
            for earning in MyRealm.realm.objects(Earning.self).sorted(byKeyPath: "dateInDateFormat") {
                
                if dateFormatterMonth.string(from: earning.dateInDateFormat).firstUppercased == month {
                    
                    if dayArray.contains(dateFormatterDay.string(from: earning.dateInDateFormat)) == false {
                        
                        dayArray.append(dateFormatterDay.string(from: earning.dateInDateFormat))
                        valueArray.append((earning.totalEarningInDollars.rounded()))
                        
                    } else { valueArray[dayArray.firstIndex(of: dateFormatterDay.string(from: earning.dateInDateFormat))!] += earning.totalEarningInDollars.rounded() }
                    
                }
            }
            
        }
        
        for day1 in sortedDays {
            
            for (index2, day2) in dayArray.enumerated() {
                
                if day1 == day2 {
                    
                    newValues.append(valueArray[index2])
                    newArrayOfDays.append(day1)
                    
                }
                
            }
            
        }
        
        return (newArrayOfDays, newValues)
    }

    //???????????? ???? ???????????? ???? ?????? ?????????? ?????? ???? ??????????
    static func sitesForCharts(itsForMonth: Bool, month: String) -> [String: Double] {
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "LLLL yy"
        
        var siteEarningDict: [String: Double] = ["" : 0.0]
        
        if !itsForMonth {
        
        for earning in MyRealm.realm.objects(Earning.self).sorted(byKeyPath: "siteName") {
            
            if siteEarningDict[earning.siteName] != nil {
                
                siteEarningDict[earning.siteName]! += (earning.totalEarningInDollars.rounded())
                
            } else { siteEarningDict[earning.siteName] = (earning.totalEarningInDollars.rounded()) }
            
        }
        } else {
            
            for earning in MyRealm.realm.objects(Earning.self).sorted(byKeyPath: "dateInDateFormat") {
                
                if dateFormatter.string(from: earning.dateInDateFormat).firstUppercased == month {
                    
                    if siteEarningDict[earning.siteName] != nil {
                        
                        siteEarningDict[earning.siteName]! += earning.totalEarningInDollars.rounded()
                        
                    } else { siteEarningDict[earning.siteName] = earning.totalEarningInDollars.rounded() }
                    
                }
                
            }
            
        }
        
        for (key, value) in siteEarningDict {
            
            if value == 0 {siteEarningDict.removeValue(forKey: key)}
            
        }
        
        
        return siteEarningDict
    }
    
}
