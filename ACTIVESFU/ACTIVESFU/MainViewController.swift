//
//  MainViewController.swift
//  Developed by Bronwyn Biro, Carber Zhang, Nathan Cheung
//
//  Using the coding standard provided by eure: github.com/erue/swift-style-guide
//
//  The main menu hub the user will interact with. This screen branches out into the main app features such
//  as view buddies, matching, creating events and logging out. The app starts on this page and checks if the user is logged in.
//  if yes, the app stays on the page. If not, the app forces the user out and is brought to the login screen.
//
//  Bugs:
//  user starts logged in, seems like the uid is hardcoded to test99@gmail.com -FIXED
//
//
//  Changes:
//
//  Completed auto login
//  Changed initial view to this one for autologin feature
//
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.


import UIKit

import Firebase


//MARK: MainViewController


class MainViewController: UIViewController {
    
    
    //MARK: Internal
    
    @IBAction func viewBuddiesSegue(_ sender: UIButton) {
        
        let buddiesController = storyboard?.instantiateViewController(withIdentifier: "viewBuddiesID") as! BuddiesViewController
        present(buddiesController, animated: true, completion: nil)
    }
    
    
    @IBAction func logoutButton(_ sender: UIButton) {
        
        handleLogout()
    }
    
    @IBAction func calendarSegue(_ sender: UIButton) {

        let calendarController = storyboard?.instantiateViewController(withIdentifier: "calendarViewID") as! ViewCalendarController

        present(calendarController, animated: true, completion: nil)
    }
    
    func checkIfUserIsLoggedIn() {
        
        if FIRAuth.auth()?.currentUser?.uid == nil {
            print("user isn't logged in")
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }
        else {
            
            print("User is logged in")
        }
    }
    
    
    
    func handleLogout() {
        
        do {
            
            try FIRAuth.auth()?.signOut()
        } catch let logoutError { print(logoutError) }
        
        let loginController = storyboard?.instantiateViewController(withIdentifier: "LoginViewID") as! LoginViewController
        present(loginController, animated: true, completion: nil)
    }
    
    
    //MARK: UIViewController
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
    }
}

