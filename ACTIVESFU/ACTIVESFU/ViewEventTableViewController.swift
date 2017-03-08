//
//  ViewEventTableViewController.swift
//  ACTIVESFU
//
//  Created by Xue Han on 2017-03-06.
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.
//

import UIKit
import Firebase

class ViewEventTableViewController: UITableViewController {
    
    var cellID = "cellID"
    var events = [Event]()


    //date passed from calendar:
    var dateIDView: String!
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
    }
    
    //-----------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationController?.navigationBar.isHidden = true
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissView))
        
        tableView.register(EventCell.self, forCellReuseIdentifier: cellID)
        
        
        //viewEventDetials()
        fetchEvent()
        
        
    }
    
    func dismissView() {
        
        dismiss(animated: true, completion: nil)
    }
    
    func fetchEvent() {
        let ref = FIRDatabase.database().reference()
        ref.child("Events").queryOrdered(byChild: "date").queryEqual(toValue: "\(dateIDView ?? "")").observe(.childAdded, with: { (snapshot) in
            
            
            if let dictionary = snapshot.value as? [String: String] {
                let eventNow = Event()
                
                // If you use this setter, the app will crash IF the class properties don't exactly match up with the firebase dictionary keys
                eventNow.setValuesForKeys(dictionary)
                
                self.events.append(eventNow)
                
                // This will crash because of background thread, so the dispatch fixes it
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
                //print(eventNow.title, eventNow.date)

            }
            
        },withCancel: nil)    }
    
   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        
        let event = events[indexPath.row]
        
        
        cell.textLabel?.text = event.title
        cell.detailTextLabel?.numberOfLines = 4
        
        cell.detailTextLabel?.text = event.date
        
        return cell
    }

    
    
}

class EventCell: UITableViewCell{
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
}


