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
//  Hardcoded match, need to expand to all similar things
//
//
//
//
//  Changes:
//  Changed from location -> similar interests
//  Ensured that a user won't see themself in the recommended list 
//
//
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.

import UIKit
import Firebase
import CoreLocation

class FindABuddyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var directionsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let cell = "cell"
    var userFormatInDatabase = [User]()
    var sportsUsers = [String]()
    var usersForTable = [User]()
    var unique = [String]()
    
    var firebaseReference: FIRDatabaseReference!
    var uid = FIRAuth.auth()?.currentUser?.uid
    var ref = FIRDatabase.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.register(Cell.self, forCellReuseIdentifier: cell)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
           print("shaking")
            fetchAllBuddiesInDatabase()
            fetchSurveyResults()
            tableView.reloadData()
        }
    }
    
    //MARK: database functions
    
    func fetchAllBuddiesInDatabase() {
        
        FIRDatabase.database().reference().child("Users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: String] {
                
                let singleUserInDatabase = User()
                singleUserInDatabase.id = snapshot.key
                
                // If you use this setter, the app will crash IF the class properties don't exactly match up with the firebase dictionary keys
                
                singleUserInDatabase.setValuesForKeys(dictionary)

                self.userFormatInDatabase.append(singleUserInDatabase)
            
                
                // This will crash because of background thread, so the dispatch fixes it
                
                DispatchQueue.main.async {
                    
                    self.tableView.reloadData()
                }
            }
        }, withCancel: nil)
    }
    
    

    func fetchSurveyResults(){
            let databaseRef = FIRDatabase.database().reference()
            databaseRef.child("Survey").observe(.value, with: {
            snapshot in
                
                for childSnap in snapshot.children.allObjects {
                
                    let snap = childSnap as! FIRDataSnapshot
    
                    if let snapshotValue = snapshot.value as? NSDictionary, let snapVal = snapshotValue[snap.key] as? NSDictionary {
                        
                        //to be used in V3
                        let level = snapshotValue.object(forKey: "FitnessLevel") as! NSDictionary
                        let time = snapshotValue.object(forKey: "TimeOfDay") as! NSDictionary
                        let activities = snapshotValue.object(forKey: "FavActivity") as! NSDictionary
                        let avail = snapshotValue.object(forKey: "DaysAvail") as! NSDictionary
                        
                        //hard coded for now: return all users who like sports
                        let sports = activities["Sports"] as! NSDictionary
            
                        let snapKeys = snapVal.allKeys as! [String]
                        let snapVals = snapVal.allValues

                        
                        let sportsUID = sports.allKeys
                        
                        
                        for item in sportsUID {
                            let item = String(describing: item)
                                self.sportsUsers.append(item)

                        }
                        
                        self.sportsUsers = Array(Set(self.sportsUsers))
                        
                        //Remove myself from showing up
                        for user in self.userFormatInDatabase {
                            let currentUID = user.id
                            if self.sportsUsers.contains(currentUID!){
                                if currentUID != self.uid {
                                    self.usersForTable.append(user)
                                }
                            }
                        }
                        print("-------------------------------------", self.usersForTable)
                      
                        /*
                        print("----------------------------snapvals", snapVals)
                        print("----------------------------snapvkey", snapKeys)
                        print("unique array-----------------------", self.unique)
                        print("unique array count------------", self.unique.count)
                        */
                         self.tableView.reloadData()
                       
                    }
                }
                
        })
    }
    

    //MARK: table view functions
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let usersForTable = Array(Set(self.usersForTable))
        return usersForTable.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        //setup UI
        let tableCell = tableView.dequeueReusableCell(withIdentifier: cell, for: indexPath)
        tableCell.backgroundColor = UIColor.clear
        tableCell.textLabel?.textColor = UIColor.white
        tableCell.detailTextLabel?.textColor = UIColor.white
        
        
        let userAtRow = usersForTable[indexPath.row]
        tableCell.textLabel?.text = userAtRow.user
        //tableCell.textLabel?.text = userInDatabase.user
        tableCell.detailTextLabel?.text = "Also likes sports"
        return tableCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 72
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var user = self.usersForTable[indexPath.row]
        
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

 
