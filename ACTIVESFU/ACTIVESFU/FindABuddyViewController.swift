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
//
//
//
//  Changes:
//  Changed from location based to similar interests
//  Ensured that a user won't see themself in the recommended list
//  Generalized interests from hard coded
//  Shows common interests
//  Removed duplicates users
//
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
    
    var suggestedUsers = [User]()
    
    //User's survey results
    var myDays = [String]()
    var myTime = [String]()
    var myActivity = [String]()
    var myLevel = [String]()
    var commonInterests = [String]()
    
    //Other users results
    var commonActivity = Set<String>()
    var commonLevel = Set<String>()
    var commonTime =  Set<String>()
    var commonDays = Set<String>()

    
    var firebaseReference: FIRDatabaseReference!
    var uid = FIRAuth.auth()?.currentUser?.uid
    var ref = FIRDatabase.database().reference()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.register(Cell.self, forCellReuseIdentifier: cell)
        self.fetchSurveyResults()
        self.fetchAllBuddiesInDatabase()
        
        
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

        FIRDatabase.database().reference().child("Users").observe(.childAdded, with: { (snapshot) in
            var seenUIDS = [String]()
        
            for userBuddies in snapshot.children.allObjects as! [FIRDataSnapshot] {
                
                            if let dictionary = snapshot.value as? [String: Any] {
                                
                                let singleUserInDatabase = User()
                                singleUserInDatabase.id = snapshot.key
                                
                                print("singleuser.id--------", snapshot.key)
                                
                                let name = dictionary["user"] as! String
                                print("name:", name)
                                
                                singleUserInDatabase.user = name
                                // If you use this setter, the app will crash IF the class properties don't exactly match up with the firebase dictionary keys
                                
                                singleUserInDatabase.setValuesForKeys(dictionary)
                                
                                if seenUIDS.contains(singleUserInDatabase.id!){
                                    print("duplicate----", singleUserInDatabase.id!)
                                }
                                else {
                                    print("unique uid---", singleUserInDatabase.id!)
                                    self.userFormatInDatabase.append(singleUserInDatabase)
                                    seenUIDS.append(singleUserInDatabase.id!)
                                }
                                
                                // This will crash because of background thread, so the dispatch fixes it
                                DispatchQueue.main.async {
                                    
                            //self.tableView.reloadData()
                    }
                }
            }
        })
    }
  
    func fetchSurveyResults(){
        let databaseRef = FIRDatabase.database().reference()
        databaseRef.child("Users").child("\(uid!)").observe(.value, with: {
            snapshot in
            
            for childSnap in snapshot.children.allObjects {
                
                let snap = childSnap as! FIRDataSnapshot
                
                if let snapshotValue = snapshot.value as? NSDictionary, let snapVal = snapshotValue[snap.key]  {
                    
                    let myAvailability = snapshotValue.object(forKey: "DaysAvail") as! NSDictionary
                    self.myDays = myAvailability.allKeys as! [String]
                    print("-----------my avail", self.myDays)
                    
                    let myTimeOfDay = snapshotValue.object(forKey: "TimeOfDay") as! NSDictionary
                    self.myTime = myTimeOfDay.allKeys as! [String]
                    print("-----------myTime", self.myTime)
                    
                    let myFavActivity = snapshotValue.object(forKey: "FavActivity") as! NSDictionary
                    self.myActivity = myFavActivity.allKeys as! [String]
                    print("-----------myActivity", self.myActivity)
                    
                    let fitnessLevel = snapshotValue.object(forKey: "FitnessLevel") as! NSDictionary
                    self.myLevel = fitnessLevel.allKeys as! [String]
                    print("-----------my level", self.myLevel)
                    
                    self.commonActivity = self.fetchCommonInterests(interestType: "FavActivity", interestArray: self.myActivity)
                    self.commonLevel = self.fetchCommonInterests(interestType: "FitnessLevel", interestArray: self.myLevel)
                    self.commonTime = self.fetchCommonInterests(interestType: "TimeOfDay", interestArray: self.myTime)
                    self.commonDays = self.fetchCommonInterests(interestType: "DaysAvail", interestArray: self.myDays)
                    
                    
                    print("common activ------------------------", self.commonActivity)
                    print("common level------------------------", self.commonLevel)
                    print("common time------------------------", self.commonTime)
                    
                    
                }
            }
            
         self.tableView.reloadData()
        })
    }
 
    
    func fetchSuggestedUserInfo(category: String, id: String, completion: @escaping (String) -> ()) {
        
        print("id:", id)
        print("category:,", category)
        
        var buddyInterestsArray = [String]()
        var buddyInterests = String()
        
       FIRDatabase.database().reference().child("Users").child(id).child(category).observeSingleEvent(of: .value, with: { (categorySnap) in
            
            for categoryItems in categorySnap.children.allObjects as! [FIRDataSnapshot] {
                
                buddyInterestsArray.append(categoryItems.key)
                
            }
            buddyInterests = buddyInterestsArray.joined(separator: ", ")
            
            completion(buddyInterests)
        })
    }
    

    func fetchCommonInterests(interestType: String, interestArray: [String]) -> Set<String> {
        var seenUsers = [String]()
        var commonInterestsSet = Set<String>()
        let databaseRef = FIRDatabase.database().reference()
        databaseRef.child("\(interestType)").observeSingleEvent(of: .value, with: {
            snapshot in
            
                
            for childSnap in snapshot.children.allObjects {
                let snap = childSnap as! FIRDataSnapshot
                
                if let snapshotValue = snapshot.value as? NSDictionary, let snapVal = snapshotValue[snap.key] {
                    
                    for item in interestArray{
                        let commonInterest = snapshotValue.object(forKey:"\(item)") as! NSDictionary
                        print("------------------------------item", item)
                        
                        // for each UID with the interest, create a user with that UID and interest
                        for suggestedUser in self.userFormatInDatabase {
                        for userWithInterest in commonInterest.allKeys as! [String]{
                            
                        if suggestedUser.id! == userWithInterest {
                            print("match")
                            
                            suggestedUser.interests.insert(item)
                            suggestedUser.id = userWithInterest
                            
                            if seenUsers.contains(suggestedUser.id!) {
                                print("duplicate:", suggestedUser.id!)
                            }
                            else {
                                
                                print("new:", suggestedUser.id!)
                                self.suggestedUsers.append(suggestedUser)
                                seenUsers.append(suggestedUser.id!)
                                
                                print("--------------------suggested user interest", Set(suggestedUser.interests))
                                print("--------------------suggested user uid", suggestedUser.id!)
                            }
                        }
                            
                            //suggestedUser.setValuesForKeys(commonInterest.allValues as! [String])
                            
                        }
                        
                        let commonInterestUIDs = commonInterest.allKeys as! [String]
                        self.commonInterests += commonInterestUIDs
                        
                        // print("------------------------------commonInterests", self.commonInterests)
                        commonInterestsSet = Set(self.commonInterests)
                        print("--------------------common set", commonInterestsSet)
                    }
                }
            }
            }
        })
        print("common activ here------------------------", self.commonActivity)
        print("--------------------common set here", commonInterestsSet)
        return commonInterestsSet
        
        
    }

    
    
    // MARK: UITableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userFormatInDatabase.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        //Setup UI
        let tableCell = tableView.dequeueReusableCell(withIdentifier: cell, for: indexPath)
        tableCell.backgroundColor = UIColor.clear
        tableCell.textLabel?.textColor = UIColor.white
        tableCell.detailTextLabel?.textColor = UIColor.white
        
        /*
        print("common level", commonLevel)
        let userAtRow = userFormatInDatabase[indexPath.row]
        tableCell.textLabel?.text = userAtRow.user
        tableCell.detailTextLabel?.text = "\(userAtRow.interests)"
        */
        let userAtRow = userFormatInDatabase[indexPath.row]
        tableCell.textLabel?.text = userAtRow.user!
        tableCell.detailTextLabel?.text = "\(userAtRow.interests)"
        
        return tableCell
    }
        
        /*
        let userInDatabase = userFormatInDatabase[indexPath.row]
        var category: String?
        var categoryDetails: String?
        
        tableCell.textLabel?.text = userInDatabase.user
        
        //randomize what kinda of info will display in viewbuddies
        let diceRoll = Int(arc4random_uniform(4)+1)
        
        switch diceRoll {
            
        case 1:
            
            category = "FavActivity"
            categoryDetails = "Preferred activity is "
            
        case 2:
            
            category = "DaysAvail"
            categoryDetails = "Available on "
            
        case 3:
            
            category = "TimeOfDay"
            categoryDetails = "Available from "
            
        case 4:
            
            category = "FitnessLevel"
            categoryDetails = "Fitness level: "
            
        default:
            break
        }
        
        //fetch the info and put into the detailtextlabel
        fetchSuggestedUserInfo(category: category!, id: userInDatabase.id!) { (buddyInfoString) in
            
            tableCell.detailTextLabel?.text = categoryDetails! + buddyInfoString
        }
        return tableCell
        
    }
 */
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 72
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let commonSet = Set(commonInterests)
        var user = Array(commonSet)[indexPath.row]
        
        print("segue here")
        
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
