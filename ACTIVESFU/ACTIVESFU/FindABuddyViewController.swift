//
//  FirstViewController.swift
//  ACTIVESFU
//
//  Created by Bronwyn Biro on 2017-02-03.
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.
//

import UIKit

class FindABuddyViewController: UIViewController {
    
    @IBOutlet weak var testLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            testLabel.text = "shaking"
        }
    }

}

