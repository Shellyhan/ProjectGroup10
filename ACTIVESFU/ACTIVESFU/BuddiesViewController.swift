//
//  SecondViewController.swift
//  ACTIVESFU
//
//  Created by Bronwyn Biro on 2017-02-03.
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.
//
// Worked on by: Ryan, Nathan, Bronwyn

import UIKit
import Firebase
import FirebaseAuth


//MARK: BuddiesViewController

class BuddiesViewController: UITableViewController{
    
    
    //MARK: Internal
    
    var cellID = "cellID"
    var userFormatInDatabase = [User]()
    
    
    @IBAction func backMenu(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func fetchAllBuddiesInDatabase() {
        
        FIRDatabase.database().reference().child("Users").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: String] {
                let singleUserInDatabase = User()
                
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
    
    func dismissView() {
        
        dismiss(animated: true, completion: nil)
    }
 
    

    func viewUsernameInDatabase() {
        
        let UID = FIRAuth.auth()?.currentUser?.uid
        FIRDatabase.database().reference().child("Users").child(UID!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: Any] {
                self.navigationItem.title = dictionary["user"] as? String
            }
        }, withCancel: nil)
    }
 
    
    
    //MARK: UITableViewController
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
        
        viewUsernameInDatabase()
        fetchAllBuddiesInDatabase()
   
            
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
            
       // fetchChatUser()
        
      
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userFormatInDatabase.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tableCell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let userInDatabase = userFormatInDatabase[indexPath.row]
        
        tableCell.textLabel?.text = userInDatabase.user
        tableCell.detailTextLabel?.text = userInDatabase.email // Comment this out if we don't want to display the email
        
        return tableCell
        
            /*
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatUserCell
            
            let user = userFormatInDatabase[indexPath.row]
            cell.textLabel?.text = user.name
            cell.detailTextLabel?.text = user.email
            
            return cell
         */
    }
    
    
    
    //MARK: UserCell
    
    
    class UserCell: UITableViewCell {
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            
            super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        }
        
        required init?(coder aDecoder: NSCoder) {
            
            fatalError("init(coder:) has not been implemented")
        }
    }
    
func showChatControllerForUser(_ user: User) {
    let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
    chatLogController.user = user
    navigationController?.pushViewController(chatLogController, animated: true)
}
    
    
    func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // dismiss(animated: true) {
        var user = self.userFormatInDatabase[indexPath.row]
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    
        
            //self.showChatControllerForUser(user)
       // }
    }
    }
    

