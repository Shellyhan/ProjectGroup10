//
//  SecondViewController.swift
//  ACTIVESFU
//
//  Created by Bronwyn Biro on 2017-02-03.
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class BuddiesViewController: UITableViewController{
    
    var cellID = "cellID"
    var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
        
        
        viewUserName()
        fetchUser()
        // Do any additional setup after loading the view, typically from a nib.
    }
    func fetchUser(){
        FIRDatabase.database().reference().child("Users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: String] {
                let user = User()
                
                // If you use this setter, the app will crash IF the class properties don't exactly match up with the firebase dictionary keys
                user.setValuesForKeys(dictionary)
                
                self.users.append(user)
                
                // This will crash because of background thread, so the dispatch fixes it
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
               
                //print("--------here in buddies\(snapshot)")

  //              user.name = dictionary["user"]
            }
        
        },withCancel: nil)    }
    
    
    func viewUserName(){
        let uid = FIRAuth.auth()?.currentUser?.uid
        FIRDatabase.database().reference().child("Users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: Any] {
                self.navigationItem.title = dictionary["user"] as? String
            }
            
            print(snapshot)
//            if let dictionary = snapshot.value as? [String: Any] {
//                self.navigation
            }, withCancel: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        let user = users[indexPath.row]
        cell.textLabel?.text = user.user
        cell.detailTextLabel?.text = user.email // Comment this out if we don't want to display the email
        return cell
    }


}

class UserCell: UITableViewCell{
   override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
}

