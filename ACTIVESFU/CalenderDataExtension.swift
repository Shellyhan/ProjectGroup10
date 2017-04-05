//
//  CalenderDataExtensionViewController.swift
//  ACTIVESFU
//
//  Created by Xue Han on 2017-03-29.
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.
//

import UIKit
import Firebase

extension ViewCalendarController {
    
    //fetch all events:
    func fetchEvent() {
        
        
        events = []
        let ref = FIRDatabase.database().reference()
        let userUid = FIRAuth.auth()?.currentUser?.uid
        //get user's reference:
        self.matchingLocation = []
        
        ref.child("Users").child(userUid!).child("FavActivity").observe(.childAdded, with: { (snapshot) in
            self.userPref = snapshot.key
            print(self.userPref)
            
            switch self.userPref {
                case self.options[0]:
                    self.matchingLocation.append(self.locations[0])
                case self.options[1]:
                    self.matchingLocation.append(self.locations[2])
                case self.options[2]:
                    self.matchingLocation.append(self.locations[0])
                case self.options[3]:
                    self.matchingLocation.append(self.locations[1])
                default:
                    self.matchingLocation = self.locations
            }
        //fetch from db to get the matching events:
        ref.child("Events").queryOrdered(byChild: "date").observe(.childAdded, with: {(snapshot) in
            
            if let dictionary = snapshot.value as? [String: Any] {
                let eventNow = Event()
                eventNow.setValuesForKeys(dictionary)
                
                self.datesWithEvent.append(eventNow.date!)
                
                eventNow.eventID = snapshot.key
                self.events.append(eventNow)
                
                //match the location:
                if (self.matchingLocation.contains(eventNow.location!)){
                    self.datesWithRecommedation.append(eventNow.date!)
                }                
            }},withCancel: nil)
        })       
    }
   
    func fetchTodayEvent() {
        
        //reset events array
        self.eventsTable = []
        self.recommendationEvents = []
        
        for eventSingle in self.events {
            if (eventSingle.date == self.selected){
                self.eventsTable.append(eventSingle)
            
                if (self.matchingLocation.contains(eventSingle.location!)){
                    self.recommendationEvents.append(eventSingle)
                }
            }
        }
        //refresh table
        self.tableView.reloadData()
    }
    
 
    func fetchUserPref(){
        let ref = FIRDatabase.database().reference()
        let userUid = FIRAuth.auth()?.currentUser?.uid
        
        self.matchingLocation = []
        //matching user's preference:
        ref.child("Users").child(userUid!).child("FavActivity").observe(.childAdded, with: { (snapshot) in
            self.userPref = snapshot.key
            print(self.userPref)
        
            switch self.userPref {
            case self.options[0]:
                self.matchingLocation.append(self.locations[0])
            case self.options[1]:
                self.matchingLocation.append(self.locations[2])
            case self.options[2]:
                self.matchingLocation.append(self.locations[0])
            case self.options[3]:
                self.matchingLocation.append(self.locations[1])
            default:
                self.matchingLocation = self.locations
            } 
        })           
        //["Gym", "Aquatics centre", "Field"] ------- ["Free weight training", "Cardiovascular training", "Yoga", "Sports"]     
    }

    
    //delete the events a month ago:
    //    func expiredEvents(){
    //        //fetch the events a month ago:
    //        let userCalendar = Calendar.current
    //        let monthAgo = formatter.string(from: userCalendar.date(byAdding: .day, value: -30, to: Date())!)
    //        print("a month ago is \(monthAgo)")
    //
    //        events = []
    //        let ref = FIRDatabase.database().reference()
    //        ref.child("Events").queryOrdered(byChild: "date").observe(.childAdded, with: { (snapshot) in
    //
    //            if let dictionary = snapshot.value as? [String: Any] {
    //
    //                let eventNow = Event()
    //                eventNow.eventID = snapshot.key
    //
    //                eventNow.setValuesForKeys(dictionary)
    //                let dateString = eventNow.date
    //                if (dateString! <= monthAgo){
    //                    print("delete this \(dateString!)")
    //                    print("delete this \(eventNow.eventID!)")
    //
    //                    let eid = eventNow.eventID!
    //
    //                    //delete in events:
    //                    FIRDatabase.database().reference().child("Events").child(eid).removeValue(
    //                        completionBlock: { (error, refer) in
    //                            if error != nil {
    //                                print("error removing")
    //                            } else {
    //                                print(refer)
    //                                print("Child Removed Correctly")
    //                            }
    //                    })
    //
    //                    //delete in Participants:
    //                    FIRDatabase.database().reference().child("Participants").observe(.childAdded, with: { (snapshot) in
    //
    //                        FIRDatabase.database().reference().child("Participants").child(snapshot.key).child(eid).removeValue(
    //                            completionBlock: { (error, refer) in
    //                                if error != nil {
    //                                    print("error removing")
    //                                } else {
    //                                    print(refer)
    //                                    print("Child Removed Correctly")
    //                                }
    //                        })
    //                    })
    //                }
    //            }
    //        },withCancel: nil)
    //    }

}
