//
//  CreateEventController.swift
//  ACTIVESFU
//
//  Created by CoolMac on 2017-03-05.
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.
//

import UIKit
import Firebase

class CreateEventController: UIViewController {

    @IBOutlet weak var eventTextField: UITextField!
    
    
    var dateID: Date! //put this in database
    //var dateID: NSDate!
    var monthName = ""
    var yearname = ""
    
    @IBOutlet weak var dateLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        dateLabel.text = monthName

        //dateLabel.text = datename/

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            ////looking for entering:
            //let owner = uid
            //var title = titleTextField.text
            //var time  = timeTextField.text
            //var date = dateTextField.text
            //var location = locationTextField.text
            //var privacy = privacyTextField.text
            //var description  = descriptionTextField.text
            //var classification = classificationTextField.text
            //var participants = [buddies]?????
            
            let owner = uid
            let title = eventTextField.text!
            let time  = "10:30"
        
        //deal with date and time:
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy MM dd"
            let dateString = dateFormatter.string(from: dateID)

        
            let location = "gym"
            let privacy = "1" //1 = open to all, 0 = owner
            let description  = "work out in gym"
            let classification = "1" // not sure yet
            let participants = [1,2,3] // fetched from buddies
            
            print("---------------------------\(dateString)")
            //insert event:
            let eventContent = ["uid": owner,
                                "title": title,
                                "time": time,
                                "date": dateString,
                                "location": location,
                                "privacy": privacy,
                                "description": description,
                                "classification": classification,
                                "participants": participants] as [String : Any]
            
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
