import Foundation
import UIKit
import JTAppleCalendar

class DateCell: JTACDayCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var earningView: UIView!
    @IBOutlet weak var todayIndicator: UIView!
    @IBOutlet weak var totalEarningLabel: UILabel!
    
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "dd MM YYYY"
        return dateFormatter
    }()
    
    let dateFormatterFullDay : DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter
    }()
    
    //конфигурация ячейки
    func configureDateCell(view: JTACDayCell?, cellState: CellState) {
        
        guard let cell = view as? DateCell else {return}
        
        if Earning.oneDayObjects(date: self.dateFormatter.string(from: cellState.date)).count != 0 {
            var totalDayEarning = 0.0
            
            for earning in Earning.oneDayObjects(date: self.dateFormatter.string(from: cellState.date)) {
                totalDayEarning += earning.totalEarningInDollars
            }
            
            totalEarningLabel.text = String(format: "%.1f", totalDayEarning) + "$"
            totalEarningLabel.isHidden = false
            earningView.isHidden = false
            
        } else {earningView.isHidden = true
            totalEarningLabel.isHidden = true
        }
        
        todayIndicator.isHidden = true
        cell.dateLabel.text = cellState.text
        cell.earningView.layer.cornerRadius = 2
        cell.todayIndicator.layer.cornerRadius = 11
        cell.layer.cornerRadius = 6
        dateTextColors(cell: cell, cellState: cellState)
        
    }
    
    //рамка ячейки при выделении
    func borderForCell(cell: DateCell, cellState: CellState) {
        
        if cellState.isSelected {
            
            UIView.animate(withDuration: 0.12, animations: {
                cell.layer.borderWidth = 1
                cell.layer.borderColor = Color.shared.hex("#003F63").cgColor
            })
            if self.dateFormatter.string(from: cellState.date) == self.dateFormatter.string(from: Date()) {
                cell.dateLabel.textColor = .white
            }
            
        } else {
            cell.layer.borderWidth = 0
            cell.backgroundColor = Color.shared.hex("#D9D9D9")
            if self.dateFormatter.string(from: cellState.date) == self.dateFormatter.string(from: Date()) {
                cell.dateLabel.textColor = .white
            }
        }
    }
    
    //цвет даты ячейки
    func dateTextColors(cell: DateCell, cellState: CellState) {
        
        if dateFormatter.string(from: cellState.date) == dateFormatter.string(from: Date()) {
            cell.todayIndicator.isHidden = false
        }
        
        if cellState.dateBelongsTo == .thisMonth {
            
            if dateFormatterFullDay.string(from: cellState.date) == "суббота" || dateFormatterFullDay.string(from: cellState.date) == "воскресенье" {
                cell.dateLabel.textColor = Color.shared.hex("#003F63")
            }
            else {
                cell.dateLabel.textColor = Color.shared.hex("#353D40")
            }
        }
        else {
            cell.dateLabel.textColor = .systemGray2
        }
    }
}
