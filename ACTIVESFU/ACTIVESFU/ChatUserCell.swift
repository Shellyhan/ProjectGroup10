//
//  ChatChatUserCell.swift
//  ACTIVESFU
//
//  Created by Bronwyn Biro on 2017-03-06.
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.
//
// Worked on by: Bronwyn

import Foundation
import UIKit
import Firebase
import UIKit
import Firebase

class ChatUserCell: UITableViewCell {
    
    var message: Message? {
        didSet {
            setupName()
            
            detailTextLabel?.text = message?.text
            
            if let seconds = message?.timestamp?.doubleValue {
                let timestampDate = Date(timeIntervalSince1970: seconds)
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm:ss a"
                timeLabel.text = dateFormatter.string(from: timestampDate)
            }
            
        }
    }
    
    fileprivate func setupName() {
        
        if let id = message?.chatBuddyId() {
            let ref = FIRDatabase.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.textLabel?.text = dictionary["name"] as? String
                    
                }
                
            }, withCancel: nil)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(timeLabel)
        
        //time label constraints
        /*
         timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
         timeLabel.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
         timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
         timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
         */
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
