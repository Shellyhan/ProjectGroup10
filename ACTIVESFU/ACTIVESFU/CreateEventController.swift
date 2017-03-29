//
//  CreateEventViewController.swift
//  Developed by Xue (Shelly) Han, Bronwyn Biro
//
//  Using the coding standard provided by eure: github.com/eure/swift-style-guide
//
//  Allows the user to create an event on the date chosen. The user can set a time and place, as well as set the privacy
//  of the event. The newly created event is then stored in Firebase where others can view it.
//
//  Bugs:
//  When editing an event, the sliders should go automatically to the time and activity for the
//  event selected
//
//  Changes:
//  Implemented location picker
//  Changed time saved to hour and date instead of day of month
//
//
//
//
//
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.

import UIKit
import Firebase

class CreateEventController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    
    //date passed from calendar:
    var dateIDCreate: String!
    
    //date passed from edit event:
    var eventToModify = Event()
    
    //set up pickers for the changing event time
    let privacies = ["Private", "Public"]
    let locations = ["Gym", "Aquatics centre", "Field"]
    let activities = ["Badminton", "Basketball", "Climbing", "Cycling", "Hiking", "Gym", "Tennis", "Yoga", "Other"]
    
    var selectedLocation = "Gym"
    var selectedPrivacy = "Private"
    var selectedActivity = "Badminton"
    
    
    
    @IBOutlet weak var activityPicker: UIPickerView!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var privacyPicker: UIPickerView!
    @IBOutlet weak var locationPicker: UIPickerView!
    @IBOutlet weak var createEventTitle: UILabel!
    @IBOutlet weak var skipBackButton: UIBarButtonItem!
    
    
    fileprivate let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.locale = Locale.current
        return formatter
    }()
    
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var createEventButtonText: UIButton!
    
    @IBAction func bookFacilityButton(_ sender: UIButton) {
        
        let bookFacility = self.storyboard?.instantiateViewController(withIdentifier: "bookFacilityID") as! BookFacilityViewController
        
        let bookAlertController = UIAlertController(title: "Book a Facility", message: "Which facility do you want to book?", preferredStyle: .alert)
        let recreationFacility = UIAlertAction(title: "Athletics and Recreation", style: .default, handler: { action in
            
            bookFacility.facilityPage = 0
            
            self.present(bookFacility, animated: true, completion: nil)
        })
        
        let aquaticsFacility = UIAlertAction(title: "Aquatics Center", style: .default, handler: { action in
            
            bookFacility.facilityPage = 1
            self.present(bookFacility, animated: true, completion: nil)
        })
        
        bookAlertController.addAction(recreationFacility)
        bookAlertController.addAction(aquaticsFacility)
        present(bookAlertController, animated: true, completion: {
            
            bookAlertController.view.superview?.isUserInteractionEnabled = true
            bookAlertController.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.backButton)))
        })
    }
    
    @IBAction func createEventButton(_ sender: UIButton) {
        
        //get the user info
        let uid = FIRAuth.auth()?.currentUser?.uid
        let ref = FIRDatabase.database().reference()
        let UsersRef = ref.child("Users").child(uid!)
        UsersRef.observeSingleEvent(of: .value, with: { (snapshot) in //print(snapshot)
        }, withCancel: nil)
        
        //create event
        let EventRef = ref.child("Events")
        let ParticipantRef = ref.child("Participants")
        var EventKey = EventRef.childByAutoId().key
        
        let activity = selectedActivity
        let IDString = "\(uid ?? "")"
        
        //refer to existing event of editing:
        if (eventToModify.date != nil) {
            EventKey = eventToModify.eventID!
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        let date = timePicker.date as NSDate!
        let timeString = dateFormatter.string(from: date as! Date)
        let location = selectedLocation
        print("location:", location)
        
        //set time of day
        let morning = dateFormatter.date(from: "4:30 am")!
        let afternoon = dateFormatter.date(from: "12:00 pm")!
        let evening = dateFormatter.date(from: "4:00 pm")!
        let night = dateFormatter.date(from: "11:00 pm")!
        var timeOfDay = ""
        
        
        let eventHour = dateFormatter.date(from: timeString)!
        
        if (eventHour >= morning && eventHour < afternoon){
            
            timeOfDay = "Morning"
        }
        else if (eventHour >= afternoon && eventHour < evening){
            
            timeOfDay = "Afternoon"
        }
        else if (eventHour >= evening && eventHour < night){
            
            timeOfDay = "Evening"
        }
      
        
        //insert event:
        let eventContent = ["uid": IDString,
                            // "title": title,
            "title": activity,
            "date": dateIDCreate,
            "time": timeString,
            "location": location,
            "timeOfDay": timeOfDay,
            "privacy": selectedPrivacy] as [String : Any]
        
        let eventUpdates = ["\(EventKey)": eventContent]
        EventRef.updateChildValues(eventUpdates)
        
        //add the event for current user:
        ParticipantRef.child(IDString).updateChildValues([EventKey: 0])
        print("--------inserted new event for me")
        
        //display event info:
        EventRef.child(EventKey).observeSingleEvent(of: .value, with: { (snapshot) in
            
            print("----------event info--------------")
            print(snapshot)
        }, withCancel: nil)
        
        let alertController = UIAlertController(title: "Create New Event", message: "Successfully created a new event", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: skipBack)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    //skip back button:
    func skipBack(alert: UIAlertAction) {
        
        self.backButton(skipBackButton)
    }
    
    
    
    //MARK: UIViewController
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        //set up UI if modifying event:
        if (eventToModify.date != nil) {
            
            //activityPicker.setValue(eventToModify.title)
            dateIDCreate = eventToModify.date
            createEventButtonText.setTitle("Update",for: .normal)
            createEventTitle.text = ("Update Event")
        }
        
        //set up test fields:
        self.privacyPicker.dataSource = self
        self.privacyPicker.delegate = self
        
        self.locationPicker.dataSource = self
        self.locationPicker.delegate = self
        
        self.activityPicker.dataSource = self
        self.activityPicker.delegate = self
        
        locationPicker.tag = 0
        privacyPicker.tag = 1
        activityPicker.tag = 2
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        textField.returnKeyType = UIReturnKeyType.done
        return true
    }
    
    //MARK: UIPicker methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch (pickerView.tag){
        case 0:
            return locations.count
        case 1:
            return privacies.count
        case 2:
            return activities.count
        default:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch (pickerView.tag){
        case 0:
            return locations[row]
        case 1:
            return privacies[row]
        case 2:
            return activities[row]
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        let tag = pickerView.tag
        switch (pickerView.tag) {
            
        case 0:
            selectedLocation = locations[row]
            break
        case 1:
            selectedPrivacy = privacies[row]
            break
        case 2:
            selectedActivity = activities[row]
            break
        default:
            selectedLocation = locations[0]
            selectedPrivacy = privacies[0]
            selectedActivity = activities[0]
            break
        }
    }
}
