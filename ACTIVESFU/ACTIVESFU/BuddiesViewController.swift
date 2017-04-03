//
//  BuddiesViewController.swift
//  Developed by Ryan Brown, Nathan Cheung, Bronwyn Biro
//
//  Using the coding standard provided by eure: github.com/eure/swift-style-guide
//
//  Allows the user to view previous buddies he or she has matched with throughout the app's use.
//  this also branches into the chat function where users can chat with matched buddies
//
//  Bugs:
//  Users in the table are all users in the database, not the ones matched to the current user.
//  //
//  Changes:
//  Added segue to chat
//  Save snapshot for user ID
//  Added more detail to View Buddies
//
//
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.

import UIKit

import Firebase
import FirebaseAuth

//MARK: BuddiesViewController

class BuddiesViewController: UITableViewController{
    
    
    //MARK: Internal
    
    
    var cellID = "cellID"
    var userFormatInDatabase = [User]()
    //testing for view only approved buddies
    let userUid = FIRAuth.auth()?.currentUser?.uid
    let referenceDatabase = FIRDatabase.database().reference()
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func backMenu(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
    }
    
    //This function fetches the buddy's survey preferences
    func fetchBuddyInfo(category: String, buddyId: String, completion: @escaping (String) -> ()) {
       
        var buddyInterestsArray = [String]()
        var buddyInterests = String()
        
        referenceDatabase.child("Users").child(buddyId).child(category).observeSingleEvent(of: .value, with: { (categorySnap) in
            
                for categoryItems in categorySnap.children.allObjects as! [FIRDataSnapshot] {
                
                    buddyInterestsArray.append(categoryItems.key)
                    
                }
            buddyInterests = buddyInterestsArray.joined(separator: ", ")
            
            completion(buddyInterests)
        })
    }
    
    //fetches all buddies in the firebase database
    func fetchAllBuddiesInDatabase() {
        
        print("Fetching...")
        //Look in the user's buddy list
        referenceDatabase.child("Users").child(userUid!).child("Buddies").observeSingleEvent(of: .value, with: { (snapshot) in
            
            //enumerate across all buddies in the buddy list
            for userBuddies in snapshot.children.allObjects as! [FIRDataSnapshot] {
                
                //if the value is 1, then the user is blocked
                if userBuddies.value as? Int == 0 {
                    
                    //search through the user list to find the buddy
                    self.referenceDatabase.child("Users").observe(.childAdded, with: { (snapshotBuddies) in
        
                        if snapshotBuddies.key == userBuddies.key {
                            
                            //add it to the dictionary array
                            if let dictionary = snapshotBuddies.value as? [String: Any] {
    
                                let singleUserInDatabase = User()
                                singleUserInDatabase.id = snapshotBuddies.key
    
                                // If you use this setter, the app will crash IF the class properties don't exactly match up with the firebase dictionary keys
                                singleUserInDatabase.setValuesForKeys(dictionary)
                                self.userFormatInDatabase.append(singleUserInDatabase)
    
                                // This will crash because of background thread, so the dispatch fixes it
                                DispatchQueue.main.async {
    
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    }, withCancel: nil)
                }
            }
        }, withCancel: nil)
    }

    //dismissess view when pressing the back button
    func dismissView() {
        
        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: UITableViewController
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        print("ViewBuddies did load")
        tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        userFormatInDatabase.removeAll()
        tableView.reloadData()
        fetchAllBuddiesInDatabase()

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //print(userFormatInDatabase.count)
        return userFormatInDatabase.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tableCell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! UserCell
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
        fetchBuddyInfo(category: category!, buddyId: userInDatabase.id!) { (buddyInfoString) in
            
            tableCell.detailTextLabel?.text = categoryDetails! + buddyInfoString
        }

        if let profileImageUrl = userInDatabase.pic {
            
            tableCell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        return tableCell
    }
    
    
    //MARK: UserCell
    
    
    class UserCell: UITableViewCell {
        
        
        let profileImageView: UIImageView = {
            
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.layer.cornerRadius = 20
            imageView.layer.masksToBounds = true
            imageView.contentMode = .scaleAspectFill
            return imageView
        }()
        
        override func layoutSubviews() {
            
            super.layoutSubviews()
            textLabel?.frame = CGRect(x: 56, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
            detailTextLabel?.frame = CGRect(x: 56, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
        }
        
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            
            super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
            
            addSubview(profileImageView)
            
            //use constraint anchors
            //need x, y, width, height anchors
            
            profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
            profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
            profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
            profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        }
        
        required init?(coder aDecoder: NSCoder) {
            
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    func showChatControllerForUser(_ user: User) {
        
       if let chatLogSegue = self.storyboard?.instantiateViewController(withIdentifier: "chatLogID") as? ChatLogController {
           
            chatLogSegue.user = user
            let navController = UINavigationController(rootViewController: chatLogSegue)
            present(navController, animated: true, completion: nil)
        }
    }
     
    func handleCancel() {
        
        dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 72
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var user = self.userFormatInDatabase[indexPath.row]
        showChatControllerForUser(user)
    }
}
