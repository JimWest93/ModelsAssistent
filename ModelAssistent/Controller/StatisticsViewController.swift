import UIKit
import Charts

class StatisticsViewController: UIViewController {
    
    @IBOutlet weak var periodSegmentedControl: UISegmentedControl!
    @IBOutlet weak var monthPicker: UIPickerView!
    @IBOutlet weak var totalEarningLabel: UILabel!
    @IBOutlet weak var totalDaysWorkedLabel: UILabel!
    @IBOutlet weak var bestDayLabel: UILabel!
    @IBOutlet weak var bestDayEarning: UILabel!
    @IBOutlet weak var totalHoursWorkedLabel: UILabel!
    @IBOutlet weak var topSiteLabel: UILabel!
    @IBOutlet weak var topSiteEarning: UILabel!
    @IBOutlet weak var averageEarningsPerHourLabel: UILabel!
    @IBOutlet weak var bestMonthLabel: UILabel!
    @IBOutlet weak var bestMonthEarning: UILabel!
    @IBOutlet weak var sitesBarChartView: BarChartView!
    @IBOutlet weak var monthPickerHeight: NSLayoutConstraint!
    @IBOutlet weak var yearSegmentedControl: UISegmentedControl!
    @IBOutlet weak var monthDayBarChartView: BarChartView!
    @IBOutlet weak var chartsScrollView: UIScrollView!
    @IBOutlet weak var daysRatingPieView: PieChartView!
    @IBOutlet weak var bestMonthView: UIView!
    
    @IBOutlet var statsViews: [UIView]!
    
    lazy var emptyView: UIView = {
        var emptyView = UIView()
        emptyView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        emptyView.backgroundColor = Color.shared.hex("#D9D9D9")
        
        var image = UIImageView()
        image = UIImageView(frame: CGRect(x: 0, y: 0, width: emptyView.frame.size.width / 2, height: emptyView.frame.size.width / 2))
        image.image = UIImage(named: "empty")
        image.center = emptyView.center
        
        emptyView.addSubview(image)
        
        return emptyView
    }()
    
    
    var pickerData: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        monthPicker.delegate = self
        monthPicker.dataSource = self
        yearSegmentedControlSetup()
        self.view.addSubview(emptyView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewSetup()
        pickerData = Earning.allMonthWithEarning()
        monthPicker.reloadAllComponents()
        sitesBarChartSetup(siteDict: Earning.sitesForCharts(itsForMonth: false, month: ""))
        monthBarChartSetup(dataTuple: Earning.bestMonthAllTimeForCharts(year: self.yearSegmentedControl.titleForSegment(at: self.yearSegmentedControl.selectedSegmentIndex)!))
        daysPieChartSetup(daysData: Earning.daysForCharts(itsForMonth: false, month: ""))
        yearSegmentedControlSetup()
        addEmptyView()
    }
    
    //Если еще не добавлен заработок
    func addEmptyView() {
        
        if MyRealm.realm.objects(Earning.self).isEmpty {
            
            monthPicker.isHidden = true
            chartsScrollView.isHidden = true
            periodSegmentedControl.isHidden = true
            emptyView.isHidden = false
            
            UIView.animate(withDuration: 0.2,
                           animations: {
                            self.emptyView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
                           },
                           completion: { _ in
                            UIView.animate(withDuration: 0.2) {
                                self.emptyView.transform = CGAffineTransform.identity
                            }
                           })
            
        } else {
            
            emptyView.isHidden = true
            monthPicker.isHidden = false
            chartsScrollView.isHidden = false
            periodSegmentedControl.isHidden = false
            
        }
    }
    
    //настройка сегмента года
    func yearSegmentedControlSetup() {
        
        self.yearSegmentedControl.removeAllSegments()
        let years = Earning.years()
        for (index, year) in years.enumerated() {
            yearSegmentedControl.insertSegment(withTitle: year, at: index, animated: false)
        }
        
        self.yearSegmentedControl.selectedSegmentIndex = 0
        
    }
    
    @IBAction func yearSelect(_ sender: Any) {
        monthBarChartSetup(dataTuple: Earning.bestMonthAllTimeForCharts(year: self.yearSegmentedControl.titleForSegment(at: self.yearSegmentedControl.selectedSegmentIndex)!))
    }
    
    
    //выбор периода все время/месяц
    @IBAction func periodSelect(_ sender: Any) {
        
        self.chartsScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
        
        switch periodSegmentedControl.selectedSegmentIndex {
        case 0:
            
            monthPickerHeight.constant = 0
            self.view.layoutIfNeeded()
            labelsSetup()
            sitesBarChartSetup(siteDict: Earning.sitesForCharts(itsForMonth: false, month: ""))
            monthBarChartSetup(dataTuple: Earning.bestMonthAllTimeForCharts(year: self.yearSegmentedControl.titleForSegment(at: self.yearSegmentedControl.selectedSegmentIndex)!))
            daysPieChartSetup(daysData: Earning.daysForCharts(itsForMonth: false, month: ""))
            
        case 1:
            
            monthPickerHeight.constant = pickerData.count < 2 ? 50 : 100
            self.view.layoutIfNeeded()
            monthPicker.selectRow(pickerData.count - 1, inComponent: 0, animated: false)
            labelsSetup()
            sitesBarChartSetup(siteDict: Earning.sitesForCharts(itsForMonth: true, month: pickerData[monthPicker.selectedRow(inComponent: 0)]))
            monthBarChartSetup(dataTuple: Earning.bestMonthAllTimeForCharts(year: self.yearSegmentedControl.titleForSegment(at: self.yearSegmentedControl.selectedSegmentIndex)!))
            daysPieChartSetup(daysData: Earning.daysForCharts(itsForMonth: true, month: pickerData[monthPicker.selectedRow(inComponent: 0)]))
            
        default: break
        }
    }
    
    //установка лейблов
    func labelsSetup() {
        
        switch self.periodSegmentedControl.selectedSegmentIndex {
        case 0:
            
            bestDayLabel.text = Earning.bestDayAllTime().name.firstUppercased
            bestDayEarning.text = "\(Earning.bestDayAllTime().earning)" + "$"
            
            yearSegmentedControl.isHidden = false
            bestMonthView.isHidden = false
            monthDayBarChartView.isHidden = false
            
            bestMonthLabel.text = Earning.bestMonthAllTime().topMonthName.firstUppercased
            bestMonthEarning.text = String(format: "%.0f", Earning.bestMonthAllTime().topMonthEarning) + "$"
            
            totalEarningLabel.text = String(format: "%.0f", Earning.allTimeEarning()) + "$"
            totalDaysWorkedLabel.text = "\(Earning.totalDaysAndHours().days)"
            totalHoursWorkedLabel.text = "\(NSNumber(value: Earning.totalDaysAndHours().hours))"
            topSiteLabel.text = Earning.bestSiteAllTime().topSiteName
            topSiteEarning.text = String(format: "%.0f", Earning.bestSiteAllTime().topSiteEarning) + "$"
            averageEarningsPerHourLabel.text = String(format: "%.0f", Earning.averageEarningPerHourAllTime()) + "$"
            
        case 1:
            
            bestDayLabel.text = Earning.topDayForLabelMonth(month: pickerData[monthPicker.selectedRow(inComponent: 0)]).name.firstUppercased
            bestDayEarning.text = String(format: "%.0f", Earning.topDayForLabelMonth(month: pickerData[monthPicker.selectedRow(inComponent: 0)]).earning) + "$"
            yearSegmentedControl.isHidden = true
            bestMonthView.isHidden = true
            monthDayBarChartView.isHidden = true
            totalEarningLabel.text = String(format: "%.0f", Earning.totalEarningMonth(month: pickerData[monthPicker.selectedRow(inComponent: 0)])) + "$"
            totalDaysWorkedLabel.text = "\(Earning.totalDaysAndHoursMonth(month: pickerData[monthPicker.selectedRow(inComponent: 0)]).days)"
            totalHoursWorkedLabel.text = "\(NSNumber(value: Earning.totalDaysAndHoursMonth(month: pickerData[monthPicker.selectedRow(inComponent: 0)]).hours))"
            
            topSiteLabel.text = Earning.topSiteMonth(month: pickerData[monthPicker.selectedRow(inComponent: 0)]).topSiteName
            topSiteEarning.text = String(format: "%.0f", Earning.topSiteMonth(month: pickerData[monthPicker.selectedRow(inComponent: 0)]).topSiteEarning) + "$"
            averageEarningsPerHourLabel.text = String(format: "%.0f", Earning.averageEarningPerHourMonth(month: pickerData[monthPicker.selectedRow(inComponent: 0)])) + "$"
        default: break
        }
        
    }
    
    //график сайтов
    func sitesBarChartSetup(siteDict: [String: Double]) {
        
        var entries: [BarChartDataEntry] = []
        
        var xPosition = 0.0
        var sitesForX: [String] = []
        let sitesDict = siteDict
        
        for (key, value) in sitesDict.sorted(by: {$0.1 < $1.1}) {
            entries.append(BarChartDataEntry(x: xPosition, y: value))
            sitesForX.append(key)
            xPosition += 1.0
        }
        
        if entries.count > 3 {
            sitesBarChartView.xAxis.labelRotationAngle = 290
            sitesBarChartView.animate(xAxisDuration: 1, easingOption: .linear)
        } else { sitesBarChartView.xAxis.labelRotationAngle = 0 }
        
        sitesBarChartView.leftAxis.minWidth = 40
        sitesBarChartView.extraBottomOffset = 10
        sitesBarChartView.fitBars = true
        sitesBarChartView.isUserInteractionEnabled = false
        sitesBarChartView.rightAxis.enabled = false
        sitesBarChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: sitesForX)
        sitesBarChartView.xAxis.labelPosition = .bottom
        sitesBarChartView.leftAxis.axisMinimum = 0
        sitesBarChartView.xAxis.labelFont = UIFont.systemFont(ofSize: 12)
        
        sitesBarChartView.legend.enabled = false
        sitesBarChartView.xAxis.drawGridLinesEnabled = true
        sitesBarChartView.xAxis.labelCount = entries.count
        
        let dataSet = BarChartDataSet(entries: entries)
        dataSet.colors = ChartColorTemplates.joyful()
        dataSet.valueFont = UIFont.systemFont(ofSize: 10)
        
        sitesBarChartView.data = BarChartData(dataSet: dataSet)
        
    }
    
    //график дней
    func daysPieChartSetup(daysData: (day: [String], earning: [Double])) {
        
        daysRatingPieView.drawHoleEnabled = true
        daysRatingPieView.rotationAngle = 0
        daysRatingPieView.rotationEnabled = true
        daysRatingPieView.isUserInteractionEnabled = true
        daysRatingPieView.drawEntryLabelsEnabled = false
        daysRatingPieView.legend.enabled = true
        daysRatingPieView.legend.verticalAlignment = .bottom
        daysRatingPieView.legend.horizontalAlignment = .left
        daysRatingPieView.legend.orientation = .horizontal
        daysRatingPieView.holeColor = Color.shared.hex("#D9D9D9")
        daysRatingPieView.extraLeftOffset = 20
        daysRatingPieView.extraRightOffset = 20
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale.current
        numberFormatter.multiplier = 1.0
        numberFormatter.maximumFractionDigits = 0
        numberFormatter.currencySymbol = "$"
        let valuesNumberFormatter = ChartValueFormatter(numberFormatter: numberFormatter)
        
        var entries: [PieChartDataEntry] = []
        
        for (index, value) in daysData.earning.enumerated() {
            entries.append(PieChartDataEntry(value: value, label: daysData.day[index]))
        }
        
        let dataSet = PieChartDataSet(entries: entries, label: "")
        
        dataSet.colors = ChartColorTemplates.joyful()
        dataSet.valueFormatter = valuesNumberFormatter
        dataSet.xValuePosition = .outsideSlice
        dataSet.yValuePosition = .outsideSlice
        dataSet.valueColors = ChartColorTemplates.joyful()
        dataSet.sliceSpace = 2
        dataSet.drawValuesEnabled = true
        
        daysRatingPieView.data = PieChartData(dataSet: dataSet)
        daysRatingPieView.notifyDataSetChanged()
    }
    
    
    //график месяцев
    func monthBarChartSetup(dataTuple: ([String], [Double])) {
        
        let dateFormatterMonth = DateFormatter()
        dateFormatterMonth.timeZone = TimeZone.current
        dateFormatterMonth.locale = Locale(identifier: "ru_RU")
        dateFormatterMonth.dateFormat = "LLL"
        
        var entries: [BarChartDataEntry] = []
        
        var xPosition = 0.0
        
        for value in dataTuple.1 {
            entries.append(BarChartDataEntry(x: xPosition, y: value))
            xPosition += 1.0
        }
        
        if entries.count > 4 {
            monthDayBarChartView.xAxis.labelRotationAngle = 290
            monthDayBarChartView.animate(xAxisDuration: 1, easingOption: .linear)
        } else { monthDayBarChartView.xAxis.labelRotationAngle = 0 }
        
        monthDayBarChartView.leftAxis.minWidth = 40
        monthDayBarChartView.extraBottomOffset = 10
        monthDayBarChartView.fitBars = true
        monthDayBarChartView.isUserInteractionEnabled = false
        monthDayBarChartView.rightAxis.enabled = false
        monthDayBarChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataTuple.0)
        monthDayBarChartView.xAxis.labelPosition = .bottom
        monthDayBarChartView.leftAxis.axisMinimum = 0
        monthDayBarChartView.xAxis.labelFont = UIFont.systemFont(ofSize: 12)
        monthDayBarChartView.xAxis.drawGridLinesEnabled = false
        monthDayBarChartView.xAxis.labelCount = entries.count
        monthDayBarChartView.legend.enabled = false
        
        let dataSet = BarChartDataSet(entries: entries)
        dataSet.colors = ChartColorTemplates.joyful()
        dataSet.drawValuesEnabled = false
        
        monthDayBarChartView.data = BarChartData(dataSet: dataSet)
        
    }
    
    func viewSetup() {
        
        periodSegmentedControl.selectedSegmentIndex = 0
        yearSegmentedControl.selectedSegmentIndex = 0
        monthPickerHeight.constant = 0
        self.view.layoutIfNeeded()
        labelsSetup()
        
        for view in statsViews {
            view.layer.cornerRadius = 10
            view.layer.shadowColor = Color.shared.hex("#353D40").cgColor
            view.layer.shadowOffset = CGSize(width: 0, height: 2)
            view.layer.shadowRadius = 3
            view.layer.shadowOpacity = 1
            view.layer.masksToBounds = false
        }
        
        periodSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Color.shared.hex("#F2B138")], for: .selected)
        periodSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Color.shared.hex("#A1A5A6")], for: .normal)
        yearSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Color.shared.hex("#F2B138")], for: .selected)
        yearSegmentedControl.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Color.shared.hex("#A1A5A6")], for: .normal)
        overrideUserInterfaceStyle = .light
    }
    
}

extension StatisticsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.labelsSetup()
        self.sitesBarChartSetup(siteDict: Earning.sitesForCharts(itsForMonth: true, month: pickerData[monthPicker.selectedRow(inComponent: 0)]))
        self.daysPieChartSetup(daysData: Earning.daysForCharts(itsForMonth: true, month: pickerData[monthPicker.selectedRow(inComponent: 0)]))
    }
    
}
