//
//  PublicProfileViewController.swift
//  Developed by Bronwyn Biro
//
//  Using the coding standard provided by eure: github.com/eure/swift-style-guide
//
//  Allows the user to view a suggested buddy's information. It also features a "like"/"dislike" button, so users can
//  match eachother.
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
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.

import UIKit
import Firebase

class PublicProfileViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate {
    

    let databaseRef = FIRDatabase.database().reference()
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var activityText: UITextField!
    @IBOutlet weak var experienceText: UITextField!
    @IBOutlet weak var daysText: UITextField!
    @IBOutlet weak var timeText: UITextField!
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    
    //User passed from segue
    var user: User!
    
    
    
    func setupInformation() {
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.clipsToBounds = true
        
        usernameText.textAlignment = .center
        
        if let uid = user.id {
            databaseRef.child("Users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dict = snapshot.value as? [String: AnyObject] {
                    self.usernameText.text = dict["user"] as? String
                   
                    if let profileImageURL = dict["pic"] as? String {
                    
                        self.profileImage.loadImageUsingCacheWithUrlString(urlString: profileImageURL)
                    }
                }
            })
            
        }
    }

    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        print(usernameText.text!)
        usernameText.delegate = self
        setupInformation()
    }
    

    
}
