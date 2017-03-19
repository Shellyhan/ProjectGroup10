// All this does is show the basic UI right now. I had to delete
// the rest of the code in order to revert to this basic state.
//
//  ViewController.swift
//  userProfile
//
//  Created by Ryan Brown on 2017-03-16.
//  Copyright © 2017 Ryan Brown. All rights reserved.
//
// Credits to: https://github.com/aburhan/Swift-Firebase-Profile
import UIKit
import Firebase

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //  if FIRAuth.auth()?.currentUser?.uid == nil{
        //     logout()
        // }
    }
    
    // func logout(){
    // let storyboard = UIStoryboard(name: "Main", bundle: nil)
    // let loginViewController = storyboard.instantiateViewController(withIdentifier: "Login")
    //  present(loginViewController, animated: true, completion: nil)
    //}
}
