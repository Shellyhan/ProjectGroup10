//
//  CalendarViewController.swift
//  ACTIVESFU
//
//  Created by Bronwyn Biro on 2017-02-27.
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarViewController: UIViewController {

    @IBOutlet weak var calendarView: JTAppleCalendarView!


    override func viewDidLoad() {
        super.viewDidLoad()
            calendarView.dataSource = self
            calendarView.delegate = self
            calendarView.registerCellViewXib(file: "CellView")
    }
    
    
    
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
extension CalendarViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        
        let startDate = formatter.date(from: "2016 02 01")!
        let endDate = Date()
        let calendar = Calendar.current
        let parameters = ConfigurationParameters(startDate: startDate,
                                                 endDate: endDate,
                                                 numberOfRows: 6,
                                                 calendar: calendar,
                                                 generateInDates: .forAllMonths,
                                                 generateOutDates: .tillEndOfGrid,
                                                 firstDayOfWeek: .sunday)
        return parameters
    }
    func calendar(_ calendar: JTAppleCalendarView, willDisplayCell cell: JTAppleDayCellView, date: Date, cellState: CellState) {
        let myCustomCell = cell as! CellView
        
        //Setup Cell Text
        myCustomCell.dayLabel.text = cellState.text
        
        //Setup text color
        if cellState.dateBelongsTo == .thisMonth {
            myCustomCell.dayLabel.textColor = UIColor.black
        }
        else{
            myCustomCell.dayLabel.textColor = UIColor.gray
        }
    }
}
