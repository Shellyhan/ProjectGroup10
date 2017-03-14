//
//  CalendarViewController.swift
//  Developed by Nathan Cheung, Xue (Shelly) Han
//
//  Inspired by Jeron Thomas (JTAppleCalendar): github.com/patchthecode/JTAppleCalendar
//
//  Using the coding standard provided by eure: github.com/eure/swift-style-guide
//
//  View controller when the user wants to see the calendar to find or create an event.
//  A calendar will show up and the user will be able to select a date and choose to either
//  view events on that day, or create one.
//
//  Bugs:
//
//
//
//  Changes:
//
////
//  ViewController.swift
//  FSCalendarSwiftExample
//
//  Created by Wenchao Ding on 9/3/15.
//  Copyright (c) 2015 wenchao. All rights reserved.
//
//
//  this is the controller for the calendar
//
//
//
//
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.

import UIKit
import Foundation
import FSCalendar
import Firebase




class ViewCalendarController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    
    
    @IBOutlet weak var calendar: FSCalendar!
    
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!
    
 

    
    
    
    //set up navigation:
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func menuButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    func backToMenu(){
        dismiss(animated: true, completion: nil)
    }
    
    
    //set up calendar:
    fileprivate let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    /*fileprivate let formatterMonth: DateFormatter = {
        let formatterMonth = DateFormatter()
        formatterMonth.dateFormat = "yyyy/MM"
        return formatterMonth
    }()*/
    
    fileprivate let gregorian: NSCalendar! = NSCalendar(calendarIdentifier:NSCalendar.Identifier.gregorian)
    
    //set events and date:
    var datesWithEvent = [""]
    var datesWithMultipleEvents = [""]

    
    
    
    //fetch events for this month:
    /*
    func fetchEvent() {
        let ref = FIRDatabase.database().reference()
        var today = "0"
        var count = 0
        
        for dayIndex in 1...31{
        
            today = self.thisMonth + "/" + String(dayIndex)
            
            ref.child("Events").queryOrdered(byChild: "date").queryEqual(toValue: "\(today)").observe(.childAdded, with: {(snapshot) in
                
                //print("-----------here is \(today)")
                
                if (snapshot.exists()) {
                    self.datesWithEvent.append(today)
                    //print("---------it's not null in \(today)")
                    //print("-------and here is the detail \(snapshot)")
                    count = count + 1
                }else {print("nil")}
                
            },withCancel: nil)
        
        }
            //print("----------i have this many events \(count) and \(self.datesWithEvent)")

    }*/
    
    //fetch all events:
    func fetchEvent() {
        print("-------im here fetching events, will lag")
        let ref = FIRDatabase.database().reference()
        ref.child("Events").queryOrdered(byChild: "date").observe(.childAdded, with: {(snapshot) in

            if let dictionary = snapshot.value as? [String: String] {
                let eventNow = Event()
                eventNow.setValuesForKeys(dictionary)
                self.datesWithEvent.append(eventNow.date!)
            }},withCancel: nil)
        print("-------im here finished fetching events")
    }

    
    
    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchEvent()
        
        calendar.dataSource = self
        calendar.delegate = self

        self.calendar.appearance.caseOptions = [.headerUsesUpperCase,.weekdayUsesUpperCase]

        let scopeGesture = UIPanGestureRecognizer(target: self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
        self.calendar.addGestureRecognizer(scopeGesture)

        // For UITest
        self.calendar.accessibilityIdentifier = "calendar"
        
        //set up calendar properties:
        self.calendar.appearance.weekdayTextColor = UIColor.purple
        self.calendar.appearance.headerTitleColor = UIColor.purple
        self.calendar.appearance.eventDefaultColor = UIColor.red
        self.calendar.appearance.selectionColor = UIColor.purple
        self.calendar.appearance.headerDateFormat = "yyyy-MM";
        self.calendar.appearance.todayColor = UIColor.red
        self.calendar.appearance.borderRadius = 1.0
        self.calendar.appearance.headerMinimumDissolvedAlpha = 0.0
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
    
    //display events:
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateString = self.formatter.string(from: date)
        if self.datesWithEvent.contains(dateString) {
            return 1
        }
        /*if self.datesWithMultipleEvents.contains(dateString) {
            return 3
        }*/
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
        //get the events for this month:
        /*
        let thisDay:Date = Calendar.current.date(byAdding: .day, value: 1, to: calendar.currentPage)!
        thisMonth = self.formatterMonth.string(from: thisDay)
        print("-------------we are in month \(thisMonth)")
         */
        
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        let dateSelected = self.formatter.string(from: date)
        
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }

        let segueEvent = storyboard?.instantiateViewController(withIdentifier: "SelectDate_ID") as! SelectDateViewController
        segueEvent.dateID = dateSelected
        print("segue here with \(dateSelected)")
        present(segueEvent, animated: true, completion: nil)

    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
}



extension UIColor {
    
    convenience init(colorWithHexValue value: Int, alpha:CGFloat = 1.0) {
        
        self.init (
            
            red: CGFloat((value & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((value & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(value & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
