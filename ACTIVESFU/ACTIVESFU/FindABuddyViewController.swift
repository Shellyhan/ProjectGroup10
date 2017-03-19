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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.register(Cell.self, forCellReuseIdentifier: cell)
        fetchAllBuddiesInDatabase()
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
           print("shaking")
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
    
    //MARK: table view functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return userFormatInDatabase.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let tableCell = tableView.dequeueReusableCell(withIdentifier: cell, for: indexPath)
        let userInDatabase = userFormatInDatabase[indexPath.row]
        tableCell.textLabel?.text = userInDatabase.user
        tableCell.detailTextLabel?.text = "interests"
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


 
