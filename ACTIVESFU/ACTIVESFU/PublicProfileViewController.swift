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
//  User profile is not scaled down
//
//
//  Changes:
//  Shows common interests
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

    var user: User!
    
    func setupInformation() {
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.clipsToBounds = true
        
        usernameText.textAlignment = .center
        databaseRef.child("Users").child(user.id!).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dict = snapshot.value as? [String: AnyObject] {
                    self.usernameText.text = dict["user"] as? String
                   
                    if let profileImageURL = dict["pic"] as? String {
                    
                        self.profileImage.loadImageUsingCacheWithUrlString(urlString: profileImageURL)
                    }
            }
        })
    }
    
    func fetchSurveyResults(){
        let databaseRef = FIRDatabase.database().reference()
        databaseRef.child("Users").child("\(user.id!)").observe(.value, with: {
            snapshot in
            
            for _ in snapshot.children.allObjects {
                if let snapshotValue = snapshot.value as? NSDictionary {
                    
                    let myAvailability = snapshotValue.object(forKey: "DaysAvail") as! NSDictionary
                    let textForDay = myAvailability.allKeys as! [String]
                    self.daysText.text = textForDay.joined(separator: ", ")
                    
                    let myTimeOfDay = snapshotValue.object(forKey: "TimeOfDay") as! NSDictionary
                    let textForTime = myTimeOfDay.allKeys as! [String]
                    self.timeText.text = textForTime.joined(separator: ", ")
                    
                    let myFavActivity = snapshotValue.object(forKey: "FavActivity") as! NSDictionary
                    let textForActivity = myFavActivity.allKeys as! [String]
                    self.activityText.text = textForActivity.joined(separator: ", ")
                    
                    let fitnessLevel = snapshotValue.object(forKey: "FitnessLevel") as! NSDictionary
                    let textForFitness = fitnessLevel.allKeys as! [String]
                    self.experienceText.text = textForFitness.joined(separator: ", ")
                    
                }
            }
            
        })
    }


    @IBAction func dislikeButtonPressed(_ sender: Any) {
        
    }
    
    
    @IBAction func likeButtonPressed(_ sender: Any) {

        let myUID = FIRAuth.auth()?.currentUser?.uid
        let ref = FIRDatabase.database().reference()
        let newBuddyRef = ref.child("Users").child("\(myUID!)").child("Buddies")
        
        newBuddyRef.updateChildValues(["\(user.id!)": 0])
      
    }
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameText.delegate = self
        setupInformation()
        fetchSurveyResults()
    }
    

    
}
