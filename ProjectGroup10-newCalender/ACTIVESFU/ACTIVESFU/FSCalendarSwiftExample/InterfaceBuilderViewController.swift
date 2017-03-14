//
//  ViewController.swift
//  FSCalendarSwiftExample
//
//  Created by Wenchao Ding on 9/3/15.
//  Copyright (c) 2015 wenchao. All rights reserved.
//
//
//  this is the controller for the calendar
//

import UIKit

class InterfaceBuilderViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    
    @IBOutlet
    weak var calendar: FSCalendar!
    
    fileprivate weak var eventLabel: UILabel!
    
    @IBOutlet
    weak var calendarHeightConstraint: NSLayoutConstraint!
    
    //fake db:
    var datesWithEvent = ["2017/03/03", "2017/03/06", "2017/03/12", "2017/03/25"]
    var datesWithMultipleEvents = ["2017/03/14", "2017/03/20"]
    

    fileprivate var theme: Int = 0 {
        didSet {

                self.calendar.appearance.weekdayTextColor = UIColor.purple
                self.calendar.appearance.headerTitleColor = UIColor.purple
                self.calendar.appearance.eventDefaultColor = UIColor.green
                self.calendar.appearance.selectionColor = UIColor.purple
                self.calendar.appearance.headerDateFormat = "yyyy-MM";
                self.calendar.appearance.todayColor = UIColor.red
                self.calendar.appearance.borderRadius = 1.0
                self.calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        }
    }

    
    fileprivate let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    fileprivate let gregorian: NSCalendar! = NSCalendar(calendarIdentifier:NSCalendar.Identifier.gregorian)
    

    // MARK:- Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.current.model.hasPrefix("iPad") {
            self.calendarHeightConstraint.constant = 400
        }
        
        self.calendar.appearance.caseOptions = [.headerUsesUpperCase,.weekdayUsesUpperCase]
        
        let scopeGesture = UIPanGestureRecognizer(target: self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
        self.calendar.addGestureRecognizer(scopeGesture)
        
        // For UITest
        self.calendar.accessibilityIdentifier = "calendar"

    }
    
    // MARK:- FSCalendarDataSource:
    
    func calendar(_ calendar: FSCalendar, titleFor date: Date) -> String? {
        return self.gregorian.isDateInToday(date) ? ":)" : nil
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        return self.formatter.date(from: "2018/03/30")!
    }
    //event indicator
    //----------------------
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        if self.gregorian.isDateInToday(date) {
            return [UIColor.orange]
        }
        return [appearance.eventDefaultColor]
    }
    
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateString = self.formatter.string(from: date)
        if self.datesWithEvent.contains(dateString) {
            return 1
        }
        if self.datesWithMultipleEvents.contains(dateString) {
          return 3
        }
        return 0
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventColorFor date: Date) -> UIColor? {
        let dateString = self.formatter.string(from: date)
        if self.datesWithEvent.contains(dateString) {
            return UIColor.purple
        }
        return nil
    }
    //-----------------------

    // MARK:- FSCalendarDelegate

    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print("-------------change page to \(self.formatter.string(from: calendar.currentPage))")
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("----------------select date \(self.formatter.string(from: date))")
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
}

