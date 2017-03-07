//
//  SelectDateViewController.swift
//  ACTIVESFU
//
//  Created by Xue Han on 2017-03-06.
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.
//

import UIKit

class SelectDateViewController: UIViewController {
    
    
    //var dateID: Date! //put this in database
    var dateID: String!
    
    var monthName = ""
    var yearname = ""
    
    


    override func viewDidLoad() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    @IBAction func ToViewEvent(_ sender: UIButton) {
        let segueEventView = storyboard?.instantiateViewController(withIdentifier: "ViewEvent_ID") as! ViewEventTableViewController
        segueEventView.dateIDView = dateID
        present(segueEventView, animated: true, completion: nil)
        
    }
    @IBAction func ToCreateEvent(_ sender: UIButton) {
        let segueEventCreate = storyboard?.instantiateViewController(withIdentifier: "CreateEvent_ID") as! CreateEventController
        segueEventCreate.dateIDCreate = dateID
        present(segueEventCreate, animated: true, completion: nil)
    }


}
