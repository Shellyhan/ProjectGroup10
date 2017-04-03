//
//  ChatLogAlertHandlers.swift
//  ACTIVESFU
//
//  An extension file on ChatLogController.swift that handles alert views
//
//  Created by Nathan Cheung on 2017-03-28.
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.
//

import UIKit

import Firebase


extension ChatLogController {
    
    func optionsAlertHandler() {
        
        //TODO: Create an alert asking for confirmation
        let optionsAlert = UIAlertController(title: "Options", message: nil, preferredStyle: .alert)
        let blockUserOption = UIAlertAction(title: "Block User", style: .destructive) { (action) in
            
            self.blockUserHandler()
        }
        let viewProfileOption = UIAlertAction(title: "View User's Profile", style: .default) { (action) in
            self.dismissView()
            print("Option to view user's profile")
        }
        let cancelOption = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        optionsAlert.addAction(viewProfileOption)
        optionsAlert.addAction(blockUserOption)
        optionsAlert.addAction(cancelOption)
        
        present(optionsAlert, animated: true, completion: nil)
    }
    
    func blockUserHandler() {
        
        let blockUserAlert = UIAlertController(title: "Block User?", message: "Are you sure you want to block this user? This action cannot be undone.", preferredStyle: .alert)
        let confirmBlockUser = UIAlertAction(title: "Yes", style: .destructive) { (action) in
            
            let buddyId = self.user?.id
            
            //set that buddy value to 1
            self.usersDatabaseReference.child(self.userUID!).child("Buddies").child(buddyId!).setValue(1)
            
            //Do the same for the other user
            self.usersDatabaseReference.child(buddyId!).child("Buddies").child(self.userUID!).setValue(1)
            
            self.confirmUserBlocked()
        }
        let cancelBlockUser = UIAlertAction(title: "No", style: .cancel, handler: nil)
        
        blockUserAlert.addAction(confirmBlockUser)
        blockUserAlert.addAction(cancelBlockUser)
        
        present(blockUserAlert, animated: true, completion: nil)
    }
    
    func confirmUserBlocked() {
        
        let confirmUserIsBlocked = UIAlertController(title: "User Blocked", message: "The user has been succesfully blocked.", preferredStyle: .alert)
        let pressOKAlert = UIAlertAction(title: "OK", style: .default) { (action) in
            
            self.dismissView()
        }
        confirmUserIsBlocked.addAction(pressOKAlert)
        present(confirmUserIsBlocked, animated: true, completion: nil)
    }
    
    func userIsBlocked() {
        
        let userIsBlockedAlert = UIAlertController(title: "You are blocked!", message: "This user has blocked you. Your messages will not be recieved.", preferredStyle: .alert)
        let userIsBlockedAction = UIAlertAction(title: "OK", style: .default) { (action) in
            
            self.dismissView()
        }
        
        userIsBlockedAlert.addAction(userIsBlockedAction)
        self.present(userIsBlockedAlert, animated: true, completion: nil)
    }
    
}
