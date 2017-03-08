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

    @IBAction func backButton(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
    }

    @IBOutlet weak var eventTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var privacyPicker: UIPickerView!
   
    @IBOutlet weak var locationPicker: UIPickerView!
    //date passed from calendar:
    
    var dateIDCreate: String!
    var monthName = ""
    var yearname = ""
    let options = ["Private", "Public"]
    let locations = ["Gym", "Aquatics centre", "Field"]
    var selectedLocation = ""
    var selectedPrivacy = ""
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: UIViewController

    override func viewDidLoad() {
        
        super.viewDidLoad()
        eventTextField.delegate = self
        self.privacyPicker.dataSource = self
        self.privacyPicker.delegate = self
        
        self.locationPicker.dataSource = self
        self.locationPicker.delegate = self
        locationPicker.tag = 0
        privacyPicker.tag = 1
        
        //selected = options[0]
        print("------------have it \(dateIDCreate)") 
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
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView.tag == 0){
            selectedLocation = locations[row] as! String
        }
        else {
        selectedPrivacy = options[row] as! String
    }
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
        let EventKey = EventRef.childByAutoId().key
        let owner = uid
        let title = eventTextField.text!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        let date = datePicker.date as NSDate!
        var dateString = dateFormatter.string(from: date as! Date)
        print("date:", date)
        let location = selectedLocation
        let privacy = selectedPrivacy
        
        //insert event:
        
        let eventContent = ["uid": owner,
                            "title": title,
                            "date": dateIDCreate,
                            "location": location,
                            "privacy": privacy] as [String : Any]
        let eventUpdates = ["\(EventKey)": eventContent]
        EventRef.updateChildValues(eventUpdates)
        
        //display event info:
        
        EventRef.child(EventKey).observeSingleEvent(of: .value, with: { (snapshot) in
            print("----------event info--------------")
            print(snapshot)
            }, withCancel: nil)
        let alertController = UIAlertController(title: "Create New Event", message: "Successfully created a new event", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
       
        /*
         //update event:
         //example: update location and provacy:
         let location1 = "swimming pool"
         let privacy1 = "0" //1 = open to all, 0 = owner
         let eventUpateContent = [
         "location": location1,
         "privacy": privacy1]
         EventRef.child(EventKey).updateChildValues(eventUpateContent)
         */
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
