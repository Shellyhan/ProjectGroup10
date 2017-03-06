//
//  CreateEventController.swift
//  ACTIVESFU
//
//  Created by CoolMac on 2017-03-05.
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.
//  Bronwyn, Shelly

//TODO: Implement Maps integration, select location

import UIKit
import Firebase

class CreateEventController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var eventTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var privacyPicker: UIPickerView!

    let options = ["Private", "Public"]
    var selected = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.privacyPicker.dataSource = self
        self.privacyPicker.delegate = self
        selected = options[0]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: UIPicker methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selected = options[row] as! String
    }
    

    @IBAction func createEventButton(_ sender: UIButton) {
        //hardcoded user info:
        let email: String = "test99@gmail.com"
        let password: String = "123456"
        
        //login to user account:
            //checking the authentication:
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if error != nil {
                    print(error!)
                    return
                }
                else{
                    print("login successful")
                }
            })
            //get the user info
            let uid = FIRAuth.auth()?.currentUser?.uid
            let ref = FIRDatabase.database().reference()
            let UsersRef = ref.child("Users").child(uid!)
            UsersRef.observeSingleEvent(of: .value, with: { (snapshot) in
                //print(snapshot)
            }, withCancel: nil)
            
            
            //create event
            let EventRef = ref.child("Events")
            let EventKey = EventRef.childByAutoId().key
        
            let owner = uid
            let title = eventTextField.text!
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMMM dd, yyyy at hh:mm"
            let date = datePicker.date as NSDate!
            var dateString = dateFormatter.string(from: date as! Date)
            print("date:", date)
            let location = "gym"
            let privacy = selected
        
            
            
            //insert event:
            let eventContent = ["uid": owner,
                                "title": title,
                                "date": dateString,
                                "location": location,
                                "privacy": privacy] as [String : Any]
        
            
            let eventUpdates = ["\(EventKey)": eventContent]
            EventRef.updateChildValues(eventUpdates)
            
            //display event info:
            EventRef.child(EventKey).observeSingleEvent(of: .value, with: { (snapshot) in
                print("----------event info--------------")
                print(snapshot)
            }, withCancel: nil)
        
        
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
