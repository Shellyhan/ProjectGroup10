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
//  Changed from location based to similar interests
//  Ensured that a user won't see themself in the recommended list 
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
    var levelArray = [String]()
    var levelArrayUIDS = [Any]()
    //TODO remove usersfortable
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
    }
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
           print("shaking")
            fetchAllBuddiesInDatabase()
            fetchSurveyResults()
            tableView.reloadData()
        }
    }
    
    
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
    
    /*
    func fetchAvail(){
        let databaseRef = FIRDatabase.database().reference()
        databaseRef.child("DaysAvail").observe(.value, with: {
            snapshot in
            if let snapshotValue = snapshot.value as? NSDictionary, let snapVal = snapshotValue[snap.key] as? AnyObject {
                print("fetch avail value")
            }
        })
    }
 */
    
    
    func fetchSurveyResults(){
        let databaseRef = FIRDatabase.database().reference()
        databaseRef.child("Survey").observe(.value, with: {
            snapshot in
            
            for childSnap in snapshot.children.allObjects {
                
                let snap = childSnap as! FIRDataSnapshot
                // print("snapkey----------", snap.key)
                
                if let snapshotValue = snapshot.value as? NSDictionary, let snapVal = snapshotValue[snap.key] as? AnyObject {
                    let level = snapshotValue.object(forKey: "FitnessLevel") as! NSDictionary
                    
                    for (key, value) in level {
                    /*if my uid in values:
                         append my info to myInfoArray
                         append other uids to commonInterestsUIDArray eg 1234
                         append other keys in commonInterestsArray eg expert
                      else:
                         do nothing
                         
                    when done: use commonInterestsArray to display table
                    display x is also.."expert" or whatever
                    */
                    
                    self.levelArray.append(key as! String)
                    self.levelArrayUIDS.append(((value as! NSDictionary).allKeys))
                    print("----------------------levelArray", self.levelArray)
                    print("-----------------------levelArrayUID", self.levelArrayUIDS)
                    print("Value-------------: \((value as! NSDictionary).allKeys) for key---------------: \(key)")
                    }
                   
                }
            }
           self.tableView.reloadData()
        })
    }

    // MARK: UITableView
 
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let usersForTable = Array(Set(self.usersForTable))
        return usersForTable.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        //Setup UI
        let tableCell = tableView.dequeueReusableCell(withIdentifier: cell, for: indexPath)
        tableCell.backgroundColor = UIColor.clear
        tableCell.textLabel?.textColor = UIColor.white
        tableCell.detailTextLabel?.textColor = UIColor.white
        
        
        let userAtRow = usersForTable[indexPath.row]
        tableCell.textLabel?.text = userAtRow.user
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


