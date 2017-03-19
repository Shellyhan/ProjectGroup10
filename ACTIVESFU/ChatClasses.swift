//
//  ChatClasses.swift
//  
//
//  Created by Bronwyn Biro on 2017-03-06.
//
//

import Foundation
import UIKit
import FireBase

class User: NSObject {
    var id: String?
    var name: String?
    var email: String?
    var profileImageUrl: String?
}

class Message: NSObject {
    
    var fromId: String?
    var text: String?
    var timestamp: NSNumber?
    var toId: String?
    
    func chatBuddyId() -> String? {
        return fromId == FIRAuth.auth()?.currentUser?.uid ? toId : fromId
    }
    
    init(dictionary: [String: AnyObject]) {
        super.init()
        
        fromId = dictionary["fromId"] as? String
        text = dictionary["text"] as? String
        timestamp = dictionary["timestamp"] as? NSNumber
        toId = dictionary["toId"] as? String
    }
}
