//
//  FirstViewController.swift
//  ACTIVESFU
//
//  Created by Bronwyn Biro on 2017-02-03.
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class FindABuddyViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var directionsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let cell = "cell"
    var userFormatInDatabase = [User]()
    
    var firebaseReference: FIRDatabaseReference!
    let uid = FIRAuth.auth()?.currentUser?.uid
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
            //fetchSurveyResults()
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
                
                self.fetchSurveyResults(userID: singleUserInDatabase.id!)
                self.userFormatInDatabase.append(singleUserInDatabase)
                
                // This will crash because of background thread, so the dispatch fixes it
                
                DispatchQueue.main.async {
                    
                    self.tableView.reloadData()
                }
            }
        }, withCancel: nil)
    }
    
    

    func fetchSurveyResults(userID: String){
            let id = userID
            let databaseRef = FIRDatabase.database().reference()
            databaseRef.child("Survey").observe(.value, with: {
            snapshot in
                
                for childSnap in snapshot.children.allObjects {
                    
                    let snap = childSnap as! FIRDataSnapshot
    
                    
                    if let snapshotValue = snapshot.value as? NSDictionary, let snapVal = snapshotValue[snap.key] as? NSDictionary {
                        let level = snapshotValue.object(forKey: "FitnessLevel") as! NSDictionary
                        let time = snapshotValue.object(forKey: "TimeOfDay") as! NSDictionary
                        let activities = snapshotValue.object(forKey: "FavActivity") as! NSDictionary
                        let avail = snapshotValue.object(forKey: "DaysAvail") as! NSDictionary
                        
                        //hard coded for now
                        
                        let sports = activities["Sports"] as! NSDictionary
                        let friday = avail["Friday"] as! NSDictionary
                        let afternoon = time["4:30-6:30PM"] as! NSDictionary
                        
                        
                        let snapKeys = snapVal.allKeys as! [String]
                        let snapVals = snapVal.allValues
                        
                    
                        print("----------------------------snapvals", snapVals)
                        print("----------------------------snapvkey", snapKeys)
                        
                        let fridayUID = friday.allKeys
                        let sportsUID = sports.allKeys
                        let afternoonUID = afternoon.allKeys
                       
                        
                        print("----------------------------uids for friday", fridayUID)
                        
                        print("----------------------------uids for sports", sportsUID)
                        print("----------------------------afternoonArray", afternoonUID)
                            
                        /*
                        for debugging
                        let test = time.allKeys //shows all chosen answers,
                        print("level---------------------------",level)
                        print("activities----------------------", activities)
                        print("avail---------------------------", avail)
                        print("time----------------------------", time)
                        */
                    }
                }

                
        })
    }
    

    //MARK: table view functions
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return userFormatInDatabase.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        //setup UI
        let tableCell = tableView.dequeueReusableCell(withIdentifier: cell, for: indexPath)
        tableCell.backgroundColor = UIColor.clear
        tableCell.textLabel?.textColor = UIColor.white
        tableCell.detailTextLabel?.textColor = UIColor.white
        
        let userInDatabase = userFormatInDatabase[indexPath.row]
        tableCell.textLabel?.text = userInDatabase.user
        tableCell.detailTextLabel?.text = "test"
        print("---------------------------------------------", userFormatInDatabase)
        return tableCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 72
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var user = self.userFormatInDatabase[indexPath.row]
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

 
