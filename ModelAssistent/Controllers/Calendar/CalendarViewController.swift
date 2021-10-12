import UIKit
import JTAppleCalendar

class CalendarViewController: UIViewController {
    
    @IBOutlet weak var calendarCollectionView: JTACMonthView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var addEarningsButton: UIButton!
    @IBOutlet weak var statsStackView: UIStackView!
    @IBOutlet weak var totalEarningLabel: UILabel!
    @IBOutlet weak var earningPerHourLabel: UILabel!
    @IBOutlet weak var topSiteLabel: UILabel!
    @IBOutlet weak var hoursOnline: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var monthView: UIView!
    @IBOutlet weak var todayButton: UIButton!
    @IBOutlet var statsViews: [UIView]!
    
    var calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone.current
        calendar.locale = Locale(identifier: "ru_RU")
        return calendar
    }()
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "dd MM YYYY"
        return dateFormatter
    }()
    
    let dateFormatterMonthYear: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "LLLL yyyy"
        dateFormatter.locale = Locale(identifier: "ru_RU")
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        defaultSettings()
        viewSetup()
        monthLablelSetup()
        
        self.addEarningsButton.isHidden = true
        self.statsStackView.isHidden = true
        self.editButton.isHidden = true
        
        self.calendarCollectionView.scrollToDate(Date(), animateScroll: false)
        self.calendarCollectionView.selectDates([Date()])
        
        overrideUserInterfaceStyle = .light
    }
    
    func viewSetup() {

        self.monthLabel.textColor = Color.shared.hex("#F2B138")
        
        for view in statsViews {
            
            view.layer.cornerRadius = 10
            view.backgroundColor = Color.shared.hex("#353D40")
            view.layer.shadowColor = Color.shared.hex("#353D40").cgColor
            view.layer.shadowOffset = CGSize(width: 0, height: 2)
            view.layer.shadowRadius = 3
            view.layer.shadowOpacity = 1
            view.layer.masksToBounds = false
        }
        
        addEarningsButton.backgroundColor = Color.shared.hex("#F2B138")
        addEarningsButton.layer.cornerRadius = 10
        addEarningsButton.layer.shadowColor = Color.shared.hex("#353D40").cgColor
        addEarningsButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        addEarningsButton.layer.shadowRadius = 5
        addEarningsButton.layer.shadowOpacity = 1
        addEarningsButton.layer.masksToBounds = false
        
        addEarningsButton.addTarget(self, action: #selector(self.buttonAnimate), for: .allTouchEvents)
        
        self.calendarCollectionView.scrollingMode = .stopAtEachCalendarFrame
        self.calendarCollectionView.scrollDirection = .horizontal
        self.navigationController?.setNavigationBarHidden(true, animated: false)

    }
    
    //анимация кенопки добавления заработка
    @objc func buttonAnimate() {
        
        UIView.animate(withDuration: 0.2,
            animations: {
                self.addEarningsButton.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            },
            completion: { _ in
                UIView.animate(withDuration: 0.2) {
                    self.addEarningsButton.transform = CGAffineTransform.identity
                }
            })
    }
    
    //кнопка перехода на экран с таблицей сайтов для изменения заработка
    @IBAction func editEarningInSiteTable(_ sender: Any) {
        
        guard let siteTableVC = (storyboard?.instantiateViewController(identifier: "siteTableController")) as? SitesEarningsViewController else {return}
        siteTableVC.delegate = self
        siteTableVC.dateForDateLabel = self.calendarCollectionView.selectedDates.first!
        siteTableVC.editEarning = true
        siteTableVC.modalPresentationStyle = .fullScreen
        self.present(siteTableVC, animated: true, completion: nil)
        
    }
    
    //кнопка перехода на экран с таблицей сайтов для заполнения заработка
    @IBAction func toSiteTable(_ sender: Any) {
        guard let siteTableVC = (storyboard?.instantiateViewController(identifier: "siteTableController")) as? SitesEarningsViewController else {return}
        siteTableVC.delegate = self
        siteTableVC.modalPresentationStyle = .fullScreen
        siteTableVC.dateForDateLabel = self.calendarCollectionView.selectedDates.first ?? Date()
        self.present(siteTableVC, animated: true, completion: nil)
    }
    
    //лейбл месяца в хеддере
    func monthLablelSetup() {
        
        calendarCollectionView.visibleDates { (visibleDates) in
            
            let date = visibleDates.monthDates.first!.date
            self.monthLabel.text = self.dateFormatterMonthYear.string(from: date).firstUppercased
            
        }
    }
    
    //вернуться на сегодняшнюю дату
    @IBAction func scrollToToday(_ sender: Any) {
        
        self.calendarCollectionView.scrollToDate(Date(), animateScroll: false)
        self.calendarCollectionView.selectDates([Date()])
        self.showStatsViewOrButton(date: Date())
        
    }
    
    //предзапись дефолтных сайтов, процента и курса обмена, первый запуск
    func defaultSettings() {
        
        if MyRealm.realm.objects(SiteForTable.self).isEmpty {
            SiteForTable.createDeafaultSites()
        }
        
        if MyRealm.realm.objects(ModelPercentage.self).isEmpty {
            ModelPercentage.defaultModelPercentage()
        }
        
        if MyRealm.realm.objects(ExchangeRate.self).isEmpty {
            ExchangeRate.defaultExchangeRate()
        }
    
    }
    
    //установка лейблов для статс стэквью
    func labelsSetup(date: String) {
        
        self.totalEarningLabel.text = "\(String(format: "%.2f", Earning.totalDaylyEarning(date: date)))$"
        self.topSiteLabel.text = Earning.topSiteOfTheDay(date: date)
        self.earningPerHourLabel.text = "\(String(format: "%.2f", Earning.earningsPerHourPerDay(date: date)))$"
        self.hoursOnline.text = NSNumber(value: Earning.hoursOnlineOfTheDay(date: date)).stringValue
    }
    
    
    //показывать статс вью / кнопку добавления заработка
    func showStatsViewOrButton(date: Date) {
        
        if calendarCollectionView.selectedDates.count == 1 && Earning.oneDayObjects(date: self.dateFormatter.string(from: date)).isEmpty {
            self.addEarningsButton.isHidden = false
            self.statsStackView.isHidden = true
            self.editButton.isHidden = true
            
        } else if !calendarCollectionView.selectedDates.isEmpty && !Earning.oneDayObjects(date: self.dateFormatter.string(from: date)).isEmpty {
            
            labelsSetup(date: self.dateFormatter.string(from: date))
            self.addEarningsButton.isHidden = true
            self.statsStackView.isHidden = false
            self.editButton.isHidden = false
            
        }
        
        else { self.addEarningsButton.isHidden = true
            self.statsStackView.isHidden = true
            self.editButton.isHidden = true
    
        }
        
    }
    
}


//календарь делегат датасорс
extension CalendarViewController: JTACMonthViewDelegate, JTACMonthViewDataSource {
    
    //параметры календаря
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {

        let startDate = DateForCallendar.defaultDateForCallendar()
        let endDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())
        
        let parameters = ConfigurationParameters(startDate: startDate,
                                                 endDate: endDate!,
                                                 numberOfRows: 6,
                                                 calendar: self.calendar,
                                                 generateInDates: .forAllMonths,
                                                 generateOutDates: .tillEndOfGrid,
                                                 firstDayOfWeek: .monday,
                                                 hasStrictBoundaries: true)
        return parameters
    }
    
    //ячейка
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableCell(withReuseIdentifier: "dateCell", for: indexPath) as! DateCell
        
        cell.configureDateCell(view: cell, cellState: cellState)
        cell.borderForCell(cell: cell, cellState: cellState)
        cell.backgroundColor = Color.shared.hex("#D9D9D9")
        return cell
    }
    
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        
        guard let cell = cell as? DateCell else {return}
        
        cell.configureDateCell(view: cell, cellState: cellState)
        cell.borderForCell(cell: cell, cellState: cellState)
    }
    
    //скролл
    func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        self.monthLablelSetup()
    }
    
    //секлект
    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        
        guard let cell = cell as? DateCell else {return}
        
        cell.borderForCell(cell: cell, cellState: cellState)
        
        if cellState.dateBelongsTo == .followingMonthWithinBoundary {
            self.calendarCollectionView.scrollToSegment(.next)
        } else if cellState.dateBelongsTo == .previousMonthWithinBoundary { self.calendarCollectionView.scrollToSegment(.previous) }
        
        self.showStatsViewOrButton(date: cellState.date)
        
    }
    
    //деселект
    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        guard let cell = cell as? DateCell else {return}
        
        cell.borderForCell(cell: cell, cellState: cellState)
    }
}


//делегат таблицы с сайтами
extension CalendarViewController: SitesEarningDelegate {
    func reloadData(date: String, deleted: Bool) {
        
        if deleted == false {
            self.calendarCollectionView.reloadData()
            self.addEarningsButton.isHidden = true
            self.statsStackView.isHidden = false
            self.editButton.isHidden = false
            self.labelsSetup(date: date)
        } else {
            self.calendarCollectionView.reloadData()
            self.addEarningsButton.isHidden = false
            self.statsStackView.isHidden = true
            self.editButton.isHidden = true
        }
    }
}
