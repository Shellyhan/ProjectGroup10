//
//  ChatUser.swift
//  ACTIVESFU
//
//  Created by CoolMac on 2017-03-05.
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.
//
//  Class elements for retrieving user chat data
//
//  user = the user's username, email = user's email, id = user's uid in Firebase, pic = user's profile pic url in Firebase

import UIKit

class User: NSObject {
    
    var user: String?
    var email: String?
    var id: String?
    var pic: String?
    var DaysAvail: NSArray?
    var FitnessLevel: NSArray?
    var FavActivity: NSArray?
    var TimeOfDay: NSArray?
    var interests: String?
    var Buddies: NSArray?
}
