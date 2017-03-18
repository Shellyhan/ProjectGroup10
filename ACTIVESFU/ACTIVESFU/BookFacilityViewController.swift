//
//  BookFacilityViewController.swift
//  ACTIVESFU
//
//  Sets which facility rental webpage to view when the user clicks an option on the CreateEvent page.
//  '1' selects the aquatics rental page, and '0' selects the athletics rental page
//
//
//
//  Bugs:
//  Class PLBuildVersion is implemeneted in both [path] and [path]. One of the two will be used.
//      which one is undefined - We don't control either class, so we can't do anything except just report the bug
//
//  Created by Nathan Cheung
//
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.
//

import UIKit


//MARK: BookFacilityViewController


class BookFacilityViewController: UIViewController {
    
    
    //MARK: Internal
    
    var facilityPage = 0 //0 is the default, or the Athletics Facilities. 1 is Aquatics
    
    @IBOutlet weak var bookFacilityWebView: UIWebView!
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        
        bookFacilityWebView.stopLoading()
        dismiss(animated: true, completion: nil)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(facilityPage)
        let bookFacilityURL: URL
        
        if facilityPage == 0 {
            
            print("showing athletics")
            bookFacilityURL = URL(string: "http://athletics.sfu.ca/sb_output.aspx?form=18")!
        }
        else{
            
            print("showing aquatics")
            bookFacilityURL = URL(string: "http://athletics.sfu.ca/sb_output.aspx?form=20")!
        }
        
        let bookFacilityURLRequest = URLRequest(url: bookFacilityURL)
        

        bookFacilityWebView.loadRequest(bookFacilityURLRequest)
        
        bookFacilityWebView.scalesPageToFit = true
        
        bookFacilityWebView.scrollView.maximumZoomScale = 1.0
        bookFacilityWebView.scrollView.minimumZoomScale = 1.0
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
