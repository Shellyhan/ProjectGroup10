//
//  CreateEventViewController.swift
//  Developed by Bronwyn Biro, Xue (Shelly) Han
//
//  Using the coding standard provided by eure: github.com/eure/swift-style-guide
//
//  Allows the user to create an event on the date chosen. The user can set a time and place (yet to be implemented), as well as set the privacy
//  of the event. The newly created event is then stored in Firebase where others can view it.
//
//  Bugs:
//
//
//
//  Changes:
//
//
//
//
//
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.
//TODO: Implement Maps integration, select location

import UIKit
import Firebase

class CreateEventController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {


    //date passed from calendar:
    var dateIDCreate: String!
    var selectedLocation = ""
    var selectedPrivacy = ""
    
    //date passed from edit event:
    var eventToModify = Event()
    
    let options = ["Private", "Public"]
    let locations = ["Gym", "Aquatics centre", "Field"]
    
    
    @IBOutlet weak var eventTextField: UITextField!
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
        
        //create event
        let EventRef = ref.child("Events")
        var EventKey = EventRef.childByAutoId().key
        
        //refer to existing event of editing:
        if (eventToModify.date != nil) {
            EventKey = eventToModify.eventID!
        }
        
        
        let IDString = "\(uid ?? "")"
        let title = eventTextField.text!
        let location = selectedLocation
        let privacy = selectedPrivacy
        let timeSelected = formatter.string(from: timePicker.date)
        
        //insert event:
        let eventContent = ["uid": IDString,
                            "title": title,
                            "date": dateIDCreate!,
                            "time": timeSelected,
                            "location": location,
                            "privacy": privacy] as [String : Any]
        
        let eventUpdates = ["\(EventKey)": eventContent]
        EventRef.updateChildValues(eventUpdates)
        
        
        //Participants are stored separetly:
        ref.child("Participants").child(EventKey).setValue(["\(IDString)": "1"])

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
    func skipBack(alert: UIAlertAction){
        self.backButton(skipBackButton)
    }
    
    
    //MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set up UI if modifying event:
        if (eventToModify.date != nil) {
            eventTextField.text = eventToModify.title
            dateIDCreate = eventToModify.date
            createEventButtonText.setTitle("Update",for: .normal)
            createEventTitle.text = ("Update Event")
        }
        //set up test fields:
        self.timePicker.datePickerMode = UIDatePickerMode.time
        eventTextField.delegate = self
        self.privacyPicker.dataSource = self
        self.privacyPicker.delegate = self
        self.locationPicker.dataSource = self
        self.locationPicker.delegate = self
        locationPicker.tag = 0
        privacyPicker.tag = 1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        if (pickerView.tag == 0){
            return locations.count
        }
        return options.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView.tag == 0){
            return locations[row]
        }
        return options[row]
    }

    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView.tag == 0){
            selectedLocation = locations[row]
            // as! String
        }
        else{
            selectedPrivacy = options[row]// as! String
        }
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
