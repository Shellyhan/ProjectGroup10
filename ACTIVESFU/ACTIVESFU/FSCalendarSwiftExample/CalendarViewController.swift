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
//  view events on that day, or create one. Users can also modify or delete their events.
//
//  Bugs:
//  Search bar hides the first row in the event
//
//  Changes:
//  fixed lag
//  Recommended events show in table view with icon
//
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
    var eventsTable = [Event]()
    var selected = "\(Date())"
    let searchController = UISearchController(searchResultsController: nil)
    var filteredEvents = [Event]()
    var recommendationEvents = [Event]()
    
    let white = UIColor(colorWithHexValue: 0xECEAED)
    let orangeBright = UIColor(colorWithHexValue: 0xFFA500)
    let orangeDark = UIColor(colorWithHexValue: 0xFF7F50)
    
    //loading indicator:
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var activityContainer: UIView = UIView()
    var loadingView: UIView = UIView()
    
    //matching events:
    var userPref: String!
    let locations = ["Gym", "Aquatics centre", "Field"]
    let options = ["Free weight training", "Cardiovascular training", "Yoga", "Sports"]
    var matchingLocation = [String]()
    
    
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
    var datesWithEvent = [String]()
    var datesWithMultipleEvents = [String]()
    var datesWithRecommedation = [String]()
    
    
    
    // MARK:- Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()

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
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showActivityIndicator(uiView: self.view)
        
        datesWithEvent = []
        datesWithRecommedation = []
        
        //find the matching events:
        fetchEvent()
        
        //wait for events to load:
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
            
            if(self.datesWithEvent.count == 1){
                print("error loading events")
            }
            
            //reload calendar and table view:
            self.fetchTodayEvent()
            self.calendar.reloadData()
            
            //stop activity indicator once done
            self.hideActivityIndicator(uiView: self.view)
        })
        
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
    
    // MARK:- FSCalendarDataSource:
    func calendar(_ calendar: FSCalendar, titleFor date: Date) -> String? {
        return self.gregorian.isDateInToday(date) ? ":)" : nil
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        return self.formatter.date(from: "2018/03/30")!
    }

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
    
    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
        let dateString = self.formatter.string(from: date)
        return self.datesWithRecommedation.contains(dateString) ? UIImage(named: "circle2") : nil
    }

    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        let dateSelected = self.formatter.string(from: date)
        
        if monthPosition == .previous || monthPosition == .next {
            calendar.setCurrentPage(date, animated: true)
        }
        //pass to table view:
        self.selected = dateSelected
        fetchTodayEvent()
        self.tableView.reloadData()

    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        self.calendarHeightConstraint.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
 
    
    ///MARK - table view for search bar
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredEvents.count
        }
        return eventsTable.count
    }
    
  
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        cell.backgroundColor = UIColor.clear
        
        let event: Event
        if searchController.isActive && searchController.searchBar.text != "" {
            event = filteredEvents[indexPath.row]
        } else {
            event = eventsTable[indexPath.row]
        }
        
        cell.accessoryView = nil
        
        for rEvent in self.recommendationEvents {
            if (rEvent.eventID == event.eventID){
                cell.accessoryView = UIImageView(image:UIImage(named:"R_icon")!)
            }
        }
            
        cell.textLabel?.textColor = UIColor.white
        cell.detailTextLabel?.textColor = UIColor.white
        
        cell.textLabel?.text = event.title
        cell.detailTextLabel?.text = event.time
        
        return cell
    }

    
    // view event details:
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if eventsTable.count != 0 {
            
            let cellEvent = self.eventsTable[indexPath.row]

            let segueEventView = storyboard?.instantiateViewController(withIdentifier: "ViewEvent_ID") as! ViewEventDetailController
            segueEventView.uniqueEvent = cellEvent
            present(segueEventView, animated: true, completion: nil)
        }
}
    
//-----------------------------------
//define the event cells:
class EventCell: UITableViewCell{
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder aDecoder: NSCoder){
        
        fatalError("init(coder:) has not been implemented")
    }
  }
}

//MARK: more extensions:

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

