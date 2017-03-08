//
//  SelectCreateViewController.swift
//  ACTIVESFU
//
//  Created by CoolMac on 2017-03-07.
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.
//

import UIKit

class SelectDateViewController: UIViewController {

    //var dateID: Date! //put this in database
    
    var dateID: String!
    var monthName = ""
    var yearname = ""

    @IBAction func backButton(_ sender: UIBarButtonItem) {
        
        dismiss(animated: true, completion: nil)
    }
    

    override func viewDidLoad() {
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.    
    }

    @IBAction func viewEventSegue(_ sender: UIButton) {
  
        let segueEventView = storyboard?.instantiateViewController(withIdentifier: "ViewEvent_ID") as! ViewEventTableViewController
        segueEventView.dateIDView = dateID
        present(segueEventView, animated: true, completion: nil)
        
    }
    
    @IBAction func createEventSegue(_ sender: UIButton) {
   
        let segueEventCreate = storyboard?.instantiateViewController(withIdentifier: "CreateEvent_ID") as! CreateEventController
        segueEventCreate.dateIDCreate = dateID
        present(segueEventCreate, animated: true, completion: nil)  
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
