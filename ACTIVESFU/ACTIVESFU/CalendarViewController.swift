//
//  ViewController.swift
//
//  By ActiveSFU
//  Inspired by Jeron Thomas
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.
//

import UIKit
import JTAppleCalendar
import Foundation


import UIKit
import JTAppleCalendar
import Foundation


class ViewController: UIViewController {
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    
    //set variables for the calendar
    let numberOfRows = 6
    let formatter = DateFormatter()
    let testCalendar = Calendar.current
    let generateInDates: InDateCellGeneration = .forAllMonths
    let generateOutDates: OutDateCellGeneration = .tillEndOfGrid
    let firstDayofWeek: DaysOfWeek = .sunday
    
    
    //set colors
    let white = UIColor(colorWithHexValue: 0xECEAED)
    let darkPurple = UIColor(colorWithHexValue: 0x3A284C)
    let dimPurple = UIColor(colorWithHexValue: 0x574865)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formatter.dateFormat = "yyyy MM dd"
        //        formatter.timeZone = testCalendar.timeZone
        //        formatter.locale = testCalendar.locale
        
        calendarView.dataSource = self
        calendarView.delegate = self
        
        calendarView.registerCellViewXib(file: "CellView") // Registering your cell is manditory
        calendarView.cellInset = CGPoint(x: 0, y: 0)
        
        
        calendarView.visibleDates { (visibleDates: DateSegmentInfo) in
            self.setupViewsOfCalendar(from: visibleDates)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo){ //setup display of month and year
        guard let startDate = visibleDates.monthDates.first else{
            return
        }
        let month = testCalendar.dateComponents([.month], from: startDate).month!
        let monthName = DateFormatter().monthSymbols[(month-1) % 12]
        //0 indexed array
        let year = testCalendar.component(.year, from: startDate)

        monthLabel.text = monthName + " " + String(year)
        
        
    }
    
    func handleCellTextColor(view: JTAppleDayCellView?, cellState: CellState){ //configure celltextcolor
        guard let myCustomCell = view as? CellView  else {
            return
        }
        
        if cellState.isSelected {
            myCustomCell.dayLabel.textColor = darkPurple
        } else {
            if cellState.dateBelongsTo == .thisMonth {
                myCustomCell.dayLabel.textColor = white
            } else {
                myCustomCell.dayLabel.textColor = dimPurple
            }
        }
    }
    
    
    
    // Function to handle the calendar selection
    func handleCellSelection(view: JTAppleDayCellView?, cellState: CellState) {
        guard let myCustomCell = view as? CellView  else {
            return
        }
        if cellState.isSelected {
            myCustomCell.selectedView.layer.cornerRadius =  25
            myCustomCell.selectedView.isHidden = false
        } else {
            myCustomCell.selectedView.isHidden = true
        }
    }
    
    
}

extension ViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters { //configure the calendar layout
        
        let startDate = formatter.date(from: "2017 03 05")! // You can use date generated from a formatter
        let endDate = formatter.date(from: "2100 02 01")!   // You can also use dates created from this function
        
        let parameters = ConfigurationParameters(startDate: startDate,
                                                 endDate: endDate,
                                                 numberOfRows: 6,
                                                 calendar: testCalendar,
                                                 generateInDates: generateInDates,
                                                 generateOutDates: generateOutDates,
                                                 firstDayOfWeek: firstDayofWeek)
        return parameters
    }
    
    //configure calendar cells before view is loaded
    func calendar(_ calendar: JTAppleCalendarView, willDisplayCell cell: JTAppleDayCellView, date: Date, cellState: CellState) {
        let myCustomCell = cell as! CellView
        
        // Setup Cell text
        myCustomCell.dayLabel.text = cellState.text
        
        if testCalendar.isDateInToday(date){
            myCustomCell.backgroundColor = UIColor.red
        }
        else{
            myCustomCell.backgroundColor = darkPurple
        }
        
        handleCellTextColor(view: cell, cellState: cellState)
        handleCellSelection(view: cell, cellState: cellState)
    }
    
    //User selects a date then can create an event
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        handleCellSelection(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        
        //navigate to create event
        let segueEvent = storyboard?.instantiateViewController(withIdentifier: "CreateEvent_ID") as! CreateEventController
        let dateSelected = cellState.date
        
        /*
        segueEvent.monthName = "Create an event for \(dateSelected)"
        segueEvent.dateID = dateSelected
         */
        navigationController?.pushViewController(segueEvent, animated: true)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        handleCellSelection(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
    }
    
    //update month and year when scrolling the calendar
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        self.setupViewsOfCalendar(from: visibleDates)
    }
    
    
}

extension UIColor {
    convenience init(colorWithHexValue value: Int, alpha:CGFloat = 1.0){
        self.init(
            red: CGFloat((value & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((value & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(value & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
