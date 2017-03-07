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

 class BuddiesViewController: UITableViewController {
 
 let cellId = "cellId"
 var users = [User]()
 
 override func viewDidLoad() {
 super.viewDidLoad()
 
 // navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Messages", style: .plain, target: self, action: #selector(handleLogout))
 
 let image = UIImage(named: "chat")
 navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))
 
 
 tableView.register(ChatUserCell.self, forCellReuseIdentifier: cellId)
 
 //        observeMessages()
 
 tableView.allowsMultipleSelectionDuringEditing = true
 }
 
 override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
 return true
 }
 
 override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
 
 guard let uid = FIRAuth.auth()?.currentUser?.uid else {
 return
 }
 
 let message = self.messages[indexPath.row]
 
 if let chatBuddyId = message.chatBuddyId() {
 FIRDatabase.database().reference().child("user-messages").child(uid).child(chatBuddyId).removeValue(completionBlock: { (error, ref) in
 
 if error != nil {
 print("Failed to delete message:", error!)
 return
 }
 
 self.messagesDictionary.removeValue(forKey: chatBuddyId)
 self.attemptReloadOfTable()
 
 //                //this is one way of updating the table, but its actually not that safe..
 self.messages.remove(at: indexPath.row)
 self.tableView.deleteRows(at: [indexPath], with: .automatic)
 
 })
 }
 }
 
 var messages = [Message]()
 var messagesDictionary = [String: Message]()
 
 func observeChatUserMessages() {
 guard let uid = FIRAuth.auth()?.currentUser?.uid else {
 return
 }
 
 let ref = FIRDatabase.database().reference().child("user-messages").child(uid)
 ref.observe(.childAdded, with: { (snapshot) in
 
 let userId = snapshot.key
 FIRDatabase.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
 
 let messageId = snapshot.key
 self.fetchMessageWithMessageId(messageId)
 
 }, withCancel: nil)
 
 }, withCancel: nil)
 
 ref.observe(.childRemoved, with: { (snapshot) in
 print(snapshot.key)
 print(self.messagesDictionary)
 
 self.messagesDictionary.removeValue(forKey: snapshot.key)
 self.attemptReloadOfTable()
 
 }, withCancel: nil)
 }
 
 fileprivate func fetchMessageWithMessageId(_ messageId: String) {
 let messagesReference = FIRDatabase.database().reference().child("messages").child(messageId)
 
 messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
 
 if let dictionary = snapshot.value as? [String: AnyObject] {
 let message = Message(dictionary: dictionary)
 
 if let chatBuddyId = message.chatBuddyId() {
 self.messagesDictionary[chatBuddyId] = message
 }
 
 self.attemptReloadOfTable()
 }
 
 }, withCancel: nil)
 }
 
 fileprivate func attemptReloadOfTable() {
 self.timer?.invalidate()
 
 self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
 }
 
 var timer: Timer?
 
 func handleReloadTable() {
 self.messages = Array(self.messagesDictionary.values)
 self.messages.sort(by: { (message1, message2) -> Bool in
 
 return (message1.timestamp?.int32Value)! > (message2.timestamp?.int32Value)!
 })
 
 //this will crash because of background thread, so lets call this on dispatch_async main thread
 DispatchQueue.main.async(execute: {
 self.tableView.reloadData()
 })
 }
 
 override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
 return messages.count
 }
 
 override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 /*
let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ChatUserCell
 
 let message = messages[indexPath.row]
 cell.message = message
     return cell
    */
    let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
    let user = users[indexPath.row]
    cell.textLabel?.text = user.user
    cell.detailTextLabel?.text = user.email // Comment this out if we don't want to display the email
    return cell
 }
 
 override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
 return 72
 }
 
 override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
 let message = messages[indexPath.row]
 
 guard let chatBuddyId = message.chatBuddyId() else {
 return
 }
 
 let ref = FIRDatabase.database().reference().child("users").child(chatBuddyId)
 ref.observeSingleEvent(of: .value, with: { (snapshot) in
 guard let dictionary = snapshot.value as? [String: AnyObject] else {
 return
 }
 
 let user = ChatUser()
 user.id = chatBuddyId
 user.setValuesForKeys(dictionary)
 self.showChatControllerForChatUser(user)
 
 }, withCancel: nil)
 }
 
 func handleNewMessage() {
 let newMessageController = NewMessageController()
 newMessageController.buddiesViewController = self
 let navController = UINavigationController(rootViewController: newMessageController)
 present(navController, animated: true, completion: nil)
 }
 
 
 func fetchChatUserAndSetupNavBarTitle() {
 guard let uid = FIRAuth.auth()?.currentUser?.uid else {
 //for some reason uid = nil
 return
 }
 
 FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
 
 if let dictionary = snapshot.value as? [String: AnyObject] {
 //                self.navigationItem.title = dictionary["name"] as? String
 
 let user = ChatUser()
 user.setValuesForKeys(dictionary)
 self.setupNavBarWithChatUser(user)
 }
 
 }, withCancel: nil)
 }
 
 func setupNavBarWithChatUser(_ user: ChatUser) {
 messages.removeAll()
 messagesDictionary.removeAll()
 tableView.reloadData()
 
 observeChatUserMessages()
 
 let titleView = UIView()
 titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
 //        titleView.backgroundColor = UIColor.redColor()
 
 let containerView = UIView()
 containerView.translatesAutoresizingMaskIntoConstraints = false
 titleView.addSubview(containerView)
 
 let profileImageView = UIImageView()
 profileImageView.translatesAutoresizingMaskIntoConstraints = false
 profileImageView.contentMode = .scaleAspectFill
 profileImageView.layer.cornerRadius = 20
 profileImageView.clipsToBounds = true
 
 containerView.addSubview(profileImageView)
 
 //ios 9 constraint anchors
 //need x,y,width,height anchors
 profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
 profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
 profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
 profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
 
 let nameLabel = UILabel()
 
 containerView.addSubview(nameLabel)
 nameLabel.text = "test"
 nameLabel.translatesAutoresizingMaskIntoConstraints = false
 //need x,y,width,height anchors
 nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
 nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
 nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
 nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
 
 containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
 containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
 
 self.navigationItem.titleView = titleView
 
 //        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
 }
 
 func showChatControllerForChatUser(_ user: ChatUser) {
 let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
 chatLogController.user = user
 navigationController?.pushViewController(chatLogController, animated: true)
 }
 
 
 }
 
 
 
/*
class BuddiesViewController: UITableViewController{
    
    var cellID = "cellID"
    var users = [User]()
    
    //var values = ["name": name,"email": email]
    var values = ["name": "Bob", "email": "bob@sfu.ca"]
    
    class UserCell: UITableViewCell{
        override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
            super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        }
        required init?(coder aDecoder: NSCoder){
            fatalError("init(coder:) has not been implemented")
        }
        
        
        let cellId = "cellId"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
        viewUserName()
        fetchUser()
     
        //TODO: handle back button
        //navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleBack))
            
        let image = UIImage(named: "chat")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleNewMessage))

            
        tableView.register(UserCell.self, forCellReuseIdentifier: cellID)
            
            //        observeMessages()
            
            tableView.allowsMultipleSelectionDuringEditing = true
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
               // print(snapshot)
  //              user.name = dictionary["user"]
            }
        
        },withCancel: nil)
        
    
    }
    
    
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
        //return messages.count
    }
    
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        let user = users[indexPath.row]
        cell.textLabel?.text = user.user
        cell.detailTextLabel?.text = user.email // Comment this out if we don't want to display the email
        return cell
    }
    */
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! ChatUserCell
        
        let message = messages[indexPath.row]
        cell.message = message
        
        return cell
    }


    func handleNewMessage() {
        let newMessageController = NewMessageController()
        newMessageController.buddiesViewController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
    }



    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let message = self.messages[indexPath.row]
        
        if let chatBuddyId = message.chatBuddyId() {
            FIRDatabase.database().reference().child("user-messages").child(uid).child(chatBuddyId).removeValue(completionBlock: { (error, ref) in
                
                if error != nil {
                    print("Failed to delete message:", error!)
                    return
                }
                
                self.messagesDictionary.removeValue(forKey: chatBuddyId)
                self.attemptReloadOfTable()
                
                //                //this is one way of updating the table, but its actually not that safe..
                self.messages.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                
            })
        }
    }
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    
    func observeUserMessages() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            
            let userId = snapshot.key
            FIRDatabase.database().reference().child("user-messages").child(uid).child(userId).observe(.childAdded, with: { (snapshot) in
                
                let messageId = snapshot.key
                self.fetchMessageWithMessageId(messageId)
                
            }, withCancel: nil)
            
        }, withCancel: nil)
        
        ref.observe(.childRemoved, with: { (snapshot) in
            print(snapshot.key)
            print(self.messagesDictionary)
            
            self.messagesDictionary.removeValue(forKey: snapshot.key)
            self.attemptReloadOfTable()
            
        }, withCancel: nil)
    }
    
    fileprivate func fetchMessageWithMessageId(_ messageId: String) {
        let messagesReference = FIRDatabase.database().reference().child("messages").child(messageId)
        
        messagesReference.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let message = Message(dictionary: dictionary)
                
                if let chatBuddyId = message.chatBuddyId() {
                    self.messagesDictionary[chatBuddyId] = message
                }
                
                self.attemptReloadOfTable()
            }
            
        }, withCancel: nil)
    }
    
    fileprivate func attemptReloadOfTable() {
        self.timer?.invalidate()
        
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
    }
    
    var timer: Timer?
    
    //Sort by time: most recent first
    func handleReloadTable() {
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            
            return (message1.timestamp?.int32Value)! > (message2.timestamp?.int32Value)!
        })
        
        //this will crash because of background thread, so lets call this on dispatch_async main thread
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
        })
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    var BuddyController: BuddiesViewController?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatBuddyId = message.chatBuddyId() else {
            return
        }
        
        let ref = FIRDatabase.database().reference().child("users").child(chatBuddyId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject] else {
                return
            }
            
            let user = ChatUser()
            user.id = chatBuddyId
            user.setValuesForKeys(dictionary)
            self.showChatControllerForUser(user)
            
        }, withCancel: nil)
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {
            //uid = nil
            return
        }
        
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                //  self.navigationItem.title = dictionary["name"] as? String
                
                let chatUser = ChatUser()
                chatUser.setValuesForKeys(dictionary)
                self.setupNavBarWithUser(chatUser)
            }
            
        }, withCancel: nil)
    }
    
    func setupNavBarWithUser(_ user: ChatUser) {
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()
        
        observeUserMessages()
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        //  titleView.backgroundColor = UIColor.redColor()
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        
        let nameLabel = UILabel()
        
        containerView.addSubview(nameLabel)
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
        
        //  titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
    }
    
    func showChatControllerForUser(_ user: ChatUser) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
}
*/

