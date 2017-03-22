//  SelectDateViewController.swift
//  Developed by Xue (Shelly) Han
//
//  Using the coding standard provided by eure: github.com/eure/swift-style-guide
//
//  Allows the user to view the details of their event and gives them the ability to modify or delete their events. If a user is viewing an event that they didn’t create, they can join the event or message the event creator.
//
//  Bugs:
//
//
//
//  Changes:
//
//
//
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.

import UIKit
import Firebase

class ViewEventDetailController: UIViewController {

    //data from calendar
    var uniqueEvent = Event()
    var creatorID: String!
    var thisCreator = User()
    let me = FIRAuth.auth()?.currentUser?.uid

    @IBOutlet weak var EventTitle: UILabel!
    @IBOutlet weak var Time: UILabel!
    @IBOutlet weak var Location: UILabel!
    @IBOutlet weak var Creator: UILabel!
    
    @IBOutlet weak var EditButton: UIButton!
    @IBOutlet weak var RemoveButton: UIButton!
    @IBOutlet weak var JoinButton: UIButton!
    @IBOutlet weak var CreatorButton: UIButton!

    @IBOutlet weak var skipBackButton: UIBarButtonItem!
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
    }
    
    
    func fetchCreator(){
        //get creator info:
        let ref = FIRDatabase.database().reference()
        ref.child("Users").child(self.creatorID!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: String] {
                self.thisCreator.id = snapshot.key
                self.thisCreator.setValuesForKeys(dictionary)
                //wait for username:
                self.Creator.text = "Creator is:        \(self.thisCreator.user ?? "")"
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func fetchEvent(){
        
        let ref = FIRDatabase.database().reference().child("Events").child(uniqueEvent.eventID!)
        
        ref.observe(.childAdded, with: { (snapshot) in
            //reset each attribute
            switch snapshot.key {
            case "title": self.uniqueEvent.title = snapshot.value as! String?
            case "date": self.uniqueEvent.date = snapshot.value as! String?
            case "time": self.uniqueEvent.time = snapshot.value as! String?
            case "location": self.uniqueEvent.location = snapshot.value as! String?
            case "privacy": self.uniqueEvent.privacy = snapshot.value as! String?
            case "uid": self.uniqueEvent.uid = snapshot.value as! String?
            default: print("----------ERROR: extra attribute \(snapshot.key)")
            }
        },withCancel: nil)
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        //connect to DB:
        self.creatorID = self.uniqueEvent.uid
        fetchCreator()
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
        
        //setup buttons:
        if self.me == self.creatorID {
            self.JoinButton.isHidden = true
            self.CreatorButton.isHidden = true
            self.EditButton.isHidden = false
            self.RemoveButton.isHidden = false
            
        }else{
            self.JoinButton.isHidden = false
            self.CreatorButton.isHidden = false
            self.EditButton.isHidden = true
            self.RemoveButton.isHidden = true
        }
        
        //show event details:
        EventTitle.text = "Event:   \(self.uniqueEvent.title ?? "")"
        Time.text = "Time at:   \(self.uniqueEvent.date ?? "") @ \(self.uniqueEvent.time ?? "")"
        Location.text = "Location:   \(self.uniqueEvent.location ?? "")"
        
        print("Event:\n \(self.uniqueEvent.title ?? "")")
        print("Time at:\n \(self.uniqueEvent.date ?? "") @ \(self.uniqueEvent.time ?? "")")
        print("Event at:\n    \(self.uniqueEvent.location ?? "")")
        
    }
    
    
    //skip back button:
    func skipBack(alert: UIAlertAction){
        self.backButton(skipBackButton)
    }

    @IBAction func EditEvent(_ sender: UIButton) {
        //segue to Create event:
        
        //eventToModify
        let segueEventCreate = storyboard?.instantiateViewController(withIdentifier: "CreateEvent_ID") as! CreateEventController
        segueEventCreate.eventToModify = uniqueEvent
        present(segueEventCreate, animated: true, completion: nil)
        
    }

    @IBAction func DeleteEvent(_ sender: UIButton) {

        FIRDatabase.database().reference().child("Events").child(self.uniqueEvent.eventID!).removeValue(
            completionBlock: { (error, refer) in
                if error != nil {
                    print("error removing")
                } else {
                    print(refer)
                    print("Child Removed Correctly")
                }
            })

        //set alert:
        let alertController = UIAlertController(title: "Delete Event", message: "Successfully deleted this event", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: skipBack)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func JoinEvent(_ sender: UIButton) {
        
        let EventKey = FIRDatabase.database().reference().child("Participants").child(self.uniqueEvent.eventID!)
        EventKey.updateChildValues(["\(self.me ?? "")": "1"])
        print("--------inserted new participant")
        
        //set alert:
        let alertController = UIAlertController(title: "Join Event", message: "Successfully joined this event", preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: skipBack)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func ContactCreator(_ sender: UIButton) {
        print("---------go to chat with \(self.thisCreator.id)")
        showChatControllerForUser(self.thisCreator)
        
    }
    
    func showChatControllerForUser(_ creatorToPass: User) {
        
        if let chatLogSegue = self.storyboard?.instantiateViewController(withIdentifier: "chatLogID") as? ChatLogController {
            chatLogSegue.user = creatorToPass
            let navController = UINavigationController(rootViewController: chatLogSegue)
            present(navController, animated: true, completion: nil)
        }
    }

}
