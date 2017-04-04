//
//  FindABuddyViewController.swift
//  Developed by Bronwyn Biro
//
//  Using the coding standard provided by eure: github.com/eure/swift-style-guide
//
//  Allows the user to shake their phone in order to find users that they may want to connect with. Clicking
//  on a user leads to their profile and gives them the ability to connect. Matching is done through answering
//  similar things on the survey.
//
//  Bugs:
//  Make sure suggest users are NOT buddies
//  Users should dissapear if I swipe no
//  After clicking like, the user shows in suggested users until the user exits and re-shakes
//
//  Changes:
//  Changed from location based to similar interests
//  Ensured that a user won't see themself in the recommended list
//  Generalized interests from hard coded
//  Shows common interests
//  Removed duplicates users
//  Made sure I dont show myself as a suggested user
//
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.

import UIKit
import Firebase
import CoreLocation

class FindABuddyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    //MARK: Internal
    
    @IBOutlet weak var directionsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let cell = "cell"
    var userFormatInDatabase = [User]()
    var myBuddies = [String]()
    var seenUsers = [String]()
    var suggestedUsers = [User]()
    
    //User's survey results
    var myDays = [String]()
    var myTime = [String]()
    var myActivity = [String]()
    var myLevel = [String]()
    
    var firebaseReference: FIRDatabaseReference!
    var uid = FIRAuth.auth()?.currentUser?.uid
    var ref = FIRDatabase.database().reference()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.register(Cell.self, forCellReuseIdentifier: cell)
        fetchAllBuddiesInDatabase()
        self.fetchSurveyResults()
        self.fetchAllUsersInDatabase()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        
        if motion == .motionShake {
            print("shaking")
            
            self.tableView.reloadData()
        }
    }

    
    func fetchAllBuddiesInDatabase() {
        
        print("Fetching...")
        //Look in the user's buddy list
        ref.child("Users").child(uid!).child("Buddies").observeSingleEvent(of: .value, with: { (snapshot) in
            
            //enumerate across all buddies in the buddy list
            for userBuddies in snapshot.children.allObjects as! [FIRDataSnapshot] {
                
                //if the value is 1, then the user is blocked
                if userBuddies.value as? Int == 0 {
                    
                    //search through the user list to find the buddy
                    self.ref.child("Users").observe(.childAdded, with: { (snapshotBuddies) in
                        
                        if snapshotBuddies.key == userBuddies.key {
                            
                            //add it to the dictionary array
                            if let dictionary = snapshotBuddies.value as? [String: Any] {
                                
                               let buddyID = snapshotBuddies.key
                                self.myBuddies.append(buddyID)
                                
                            }
                        }
                    }, withCancel: nil)
                }
            }
        }, withCancel: nil)
    }

    
    //Get all new users
    func fetchAllUsersInDatabase() {
    
        FIRDatabase.database().reference().child("Users").observe(.childAdded, with: { (snapshot) in
            var seenUIDS = [String]()
        
            for _ in snapshot.children.allObjects as! [FIRDataSnapshot] {
                
                if let dictionary = snapshot.value as? [String: Any] {
                                
                    let singleUserInDatabase = User()
                    singleUserInDatabase.id = snapshot.key
                                
                    let name = dictionary["user"] as! String
                                
                    singleUserInDatabase.user = name
                                
                    if !seenUIDS.contains(singleUserInDatabase.id!) && !(singleUserInDatabase.id! == self.uid) {
                                    
                        self.userFormatInDatabase.append(singleUserInDatabase)
                        seenUIDS.append(singleUserInDatabase.id! )
                    }
                }
            }
        })

    }
  
    //Get my survey results, compare with other users
    func fetchSurveyResults(){
        
        let databaseRef = FIRDatabase.database().reference()
        databaseRef.child("Users").child("\(uid!)").observe(.value, with: {
            snapshot in
            
            for childSnap in snapshot.children.allObjects {
                
                if let snapshotValue = snapshot.value as? NSDictionary {
                    
                    let myAvailability = snapshotValue.object(forKey: "DaysAvail") as! NSDictionary
                    self.myDays = myAvailability.allKeys as! [String]
                    
                    let myTimeOfDay = snapshotValue.object(forKey: "TimeOfDay") as! NSDictionary
                    self.myTime = myTimeOfDay.allKeys as! [String]
                    
                    let myFavActivity = snapshotValue.object(forKey: "FavActivity") as! NSDictionary
                    self.myActivity = myFavActivity.allKeys as! [String]
                    
                    let fitnessLevel = snapshotValue.object(forKey: "FitnessLevel") as! NSDictionary
                    self.myLevel = fitnessLevel.allKeys as! [String]
                    
                    //Search for other users with the same interests, add them to the shake feature table
                    self.fetchCommonInterests(interestType: "FavActivity", interestArray: self.myActivity)
                    self.fetchCommonInterests(interestType: "FitnessLevel", interestArray: self.myLevel)
                    self.fetchCommonInterests(interestType: "TimeOfDay", interestArray: self.myTime)
                    self.fetchCommonInterests(interestType: "DaysAvail", interestArray: self.myDays)
                }
            }
        
        })
    }
    

    func fetchCommonInterests(interestType: String, interestArray: [String]) {

        let databaseRef = FIRDatabase.database().reference()
        databaseRef.child("\(interestType)").observeSingleEvent(of: .value, with: {
            snapshot in
            
            for childSnap in snapshot.children.allObjects {
                
                if let snapshotValue = snapshot.value as? NSDictionary {
                    
                    for item in interestArray{
                        let commonInterest = snapshotValue.object(forKey:"\(item)") as! NSDictionary
                        
                        // for each UID with the interest, add the interest to that user's info
                        for suggestedUser in self.userFormatInDatabase {
                        for userWithInterest in commonInterest.allKeys as! [String]{
                        
                        //ensure that the user has the given interest
                        if suggestedUser.id! == userWithInterest {
                            
                            suggestedUser.interests.insert(item)
                            suggestedUser.id = userWithInterest

                            //Make sure we don't have any duplicates or recommend myself
                            
                            if self.seenUsers.contains("\(suggestedUser.id!)") || userWithInterest == self.uid || self.myBuddies.contains("\(suggestedUser.id!)") {
                                
                                //print("Does not meet criteria", suggestedUser.id!)
                                
                            }
                            else {
                                self.suggestedUsers.append(suggestedUser)
                            }
                            self.seenUsers.append(suggestedUser.id!)
                        }
                    }
                  }
                }
              }
           }
        })
  
    }

    // MARK: UITableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.suggestedUsers.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{

        let tableCell = tableView.dequeueReusableCell(withIdentifier: cell, for: indexPath)
        tableCell.backgroundColor = UIColor.clear
        tableCell.textLabel?.textColor = UIColor.white
        tableCell.detailTextLabel?.textColor = UIColor.white
        
        let userAtRow = self.suggestedUsers[indexPath.row]
        tableCell.textLabel?.text = userAtRow.user!
        tableCell.detailTextLabel?.text = "\(userAtRow.interests.joined(separator: ", "))"
        
        return tableCell
    }
        

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 72
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userAtRow = self.suggestedUsers[indexPath.row]
        if let profileSegue = self.storyboard?.instantiateViewController(withIdentifier: "publicProfile") as? PublicProfileViewController {
            profileSegue.user = userAtRow

            let navController = UINavigationController(rootViewController: profileSegue)
            present(navController, animated: true, completion: nil)
        }
    }

    
    class Cell: UITableViewCell{
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        }
        required init?(coder aDecoder: NSCoder){
            
            fatalError("init(coder:) has not been implemented")
        }
    }
}
