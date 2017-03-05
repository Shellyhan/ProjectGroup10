//
//  CreateEventController.swift
//  ACTIVESFU
//
//  Created by CoolMac on 2017-03-05.
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.
//

import UIKit

class CreateEventController: UIViewController {

    @IBOutlet weak var eventTextField: UITextField!
    
    var dateID: Date!
    var monthName = ""
    var yearname = ""
    
    @IBOutlet weak var dateLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        dateLabel.text = monthName
        print(dateID)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func createEventButton(_ sender: UIButton) {
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
