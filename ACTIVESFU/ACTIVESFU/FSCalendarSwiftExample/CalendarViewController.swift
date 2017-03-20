//
//  CalendarViewController.swift
//  Developed by Nathan Cheung, Xue (Shelly) Han, Bronwyn Biro
//
//  
//
//  Using the coding standard provided by eure: github.com/eure/swift-style-guide
//
//  View controller when the user wants to see the calendar to find or create an event.
//  A calendar will show up and the user will be able to select a date and choose to either
//  view events on that day, or create one.
//
//  Bugs:
//  Search bar hides the first row in the event
//  Editing an event just creates a new one
//  Lag while searching
//
//
//  Changes:
//  Added search and filter bar
//  Changed appearance of table view
//
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.

import UIKit
import Foundation
import FSCalendar
import Firebase


class ViewCalendarController: UIViewController, UITableViewDataSource, UITableViewDelegate, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    
    
    @IBOutlet weak var calendar: FSCalendar!
    
    @IBOutlet weak var calendarHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var tableView: UITableView!
    
    var cellID = "cellID"
    var events = [Event]()
    var selected = "\(Date())"
    let searchController = UISearchController(searchResultsController: nil)
    var filteredEvents = [Event]()
    
    let white = UIColor(colorWithHexValue: 0xECEAED)
    let orangeBright = UIColor(colorWithHexValue: 0xFFA500)
    let orangeDark = UIColor(colorWithHexValue: 0xFF7F50)
    
    //set up navigation:
    @IBAction func CreateEventClick(_ sender: UIButton) {
        
        let segueEventCreate = storyboard?.instantiateViewController(withIdentifier: "CreateEvent_ID") as! CreateEventController
        segueEventCreate.dateIDCreate = selected
        present(segueEventCreate, animated: true, completion: nil)
    }
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    //set up calendar:
    fileprivate let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    
    fileprivate let gregorian: NSCalendar! = NSCalendar(calendarIdentifier:NSCalendar.Identifier.gregorian)
    
    //set events and date:
    var datesWithEvent = [""]
    var datesWithMultipleEvents = [""]
    
    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(EventCell.self, forCellReuseIdentifier: cellID)
        
        
        fetchEvent()
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        searchController.searchBar.delegate = self
        
        // Setup the Scope Bar
        searchController.searchBar.scopeButtonTitles = ["All", "Morning", "Afternoon", "Evening"]
        searchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = searchController.searchBar

        //TODO: change search bar to clear
        searchController.searchBar.barTintColor = UIColor.white
        searchController.searchBar.backgroundColor = UIColor.white
    }
    
    
    //refresh content shown:
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupUI()
    }
    
    //prepare data:
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchEvent()
    }
    
    
    func setupUI(){

        calendar.dataSource = self
        calendar.delegate = self
        
        self.calendar.appearance.caseOptions = [.headerUsesUpperCase,.weekdayUsesUpperCase]
        
        let scopeGesture = UIPanGestureRecognizer(target: self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
        self.calendar.addGestureRecognizer(scopeGesture)
        
        // For UITest
        self.calendar.accessibilityIdentifier = "calendar"
        
        //set up calendar properties:
        self.calendar.appearance.weekdayTextColor = white
        self.calendar.appearance.headerTitleColor = white
        self.calendar.appearance.eventDefaultColor = UIColor.magenta
        self.calendar.appearance.selectionColor = orangeDark
        self.calendar.appearance.headerDateFormat = "yyyy MMMM";
        self.calendar.appearance.todayColor = orangeBright
        self.calendar.appearance.borderRadius = 1.0
        self.calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        self.calendar.appearance.titleDefaultColor = white
        
        //event table view:
        tableView.register(EventCell.self, forCellReuseIdentifier: cellID)
    
    }
    
    
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
    }
    
    // MARK:- FSCalendarDataSource:
    
    func calendar(_ calendar: FSCalendar, titleFor date: Date) -> String? {
        return self.gregorian.isDateInToday(date) ? ":)" : nil
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        return self.formatter.date(from: "2018/03/30")!
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

    
    // MARK:- FSCalendarDelegate
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        //print("-------------change page to \(self.formatter.string(from: calendar.currentPage))")
    }

    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        let dateSelected = self.formatter.string(from: date)
        
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }
        //pass to table view:
        selected = dateSelected
        fetchTodayEvent()

    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    
    //MARK: table view 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return events.count
    }

        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.textColor = UIColor.white
        
        if events.count != 0 {
            let event = events[indexPath.row]
            cell.textLabel?.text = event.title
            cell.detailTextLabel?.text = event.time
        }
        return cell
        
    }
 
    func fetchTodayEvent() {
        //reset events array
        events = []
        let ref = FIRDatabase.database().reference()
        ref.child("Events").queryOrdered(byChild: "date").queryEqual(toValue: "\(selected )").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: String] {
                
                let eventNow = Event()
                eventNow.eventID = snapshot.key
                
                // If you use this setter, the app will crash IF the class properties don't exactly match up with the firebase dictionary keys
                
                eventNow.setValuesForKeys(dictionary)
                self.events.append(eventNow)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        },withCancel: nil)
        
        
        // Update table if no events for today:
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    /*
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredEvents.count
        }
        return events.count
    }
    
  
   
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        let event: Event
        if searchController.isActive && searchController.searchBar.text != "" {
            event = filteredEvents[indexPath.row]
        } else {
            event = events[indexPath.row]
        }
        cell.textLabel?.text = event.title
        cell.detailTextLabel?.text = event.time
        return cell
    }
 */

    
    
    //MARK: filter and search bar
    //TODO: implement time of day search
    func filterEventsForSearch(searchText: String, scope: String = "All") {
        
        filteredEvents = events.filter { event in
            
            let timeMatch = (scope == "All") || (event.timeOfDay == scope)
            
            print("event-----------------------", event.title)
            print("event.timeofDay-------------", event.timeOfDay)
            print("scope-----------------------", scope)
            print("time match-------------------", timeMatch)
            
            return timeMatch && (event.title?.lowercased().contains(searchText.lowercased()))!
        }
        tableView.reloadData()
        
        print(filteredEvents)
    }
    
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        let searchBar = searchController.searchBar
        
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        print("--------------------------scope", scope)
        
        filterEventsForSearch(searchText: searchController.searchBar.text!, scope: scope)
    }

    
    
    // view event details:
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if events.count != 0 {
            
            let cellEvent = self.events[indexPath.row]

            let segueEventView = storyboard?.instantiateViewController(withIdentifier: "ViewEvent_ID") as! ViewEventDetailController
            segueEventView.uniqueEvent = cellEvent
            present(segueEventView, animated: true, completion: nil)
        }
}

class EventCell: UITableViewCell{
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder aDecoder: NSCoder){
        
        fatalError("init(coder:) has not been implemented")
    }
  }
}


//MARK: UIColor

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

extension ViewCalendarController: UISearchResultsUpdating {
    
@available(iOS 8.0, *)
public func updateSearchResults(for searchController: UISearchController) {
    
    let searchBar = searchController.searchBar
    
    let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
    
    filterEventsForSearch(searchText: searchController.searchBar.text!, scope: scope)

    }
}



extension ViewCalendarController: UISearchBarDelegate {
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterEventsForSearch(searchText: searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

