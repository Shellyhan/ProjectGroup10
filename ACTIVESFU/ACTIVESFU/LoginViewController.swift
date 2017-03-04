//
//  LoginViewController.swift
//  ACTIVESFU
//
//  Created by Bronwyn Biro on 2017-02-27.
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    //reference to the link to Frebase DB:
    var ref: FIRDatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: Actions
    @IBAction func createAccountButton(_ sender: UIButton) {
        print("Create account was pressed")
        
        func handleRegister() {
            //wait for user input
            // guard let email = usernameTextField.text, let password = passwordTextField.text, let name = usernameTextField.text else {
            let email:String = "333@gmail.com"
            let password:String = "123456"
            let name:String = "shelly"
            let friends:Array = ["7PT0C9flfDM3RcZtdcHURzySlaJ2", "orQY3pNQxJa1h5RcBa1QrjKblQg2"]//dummy users
        
            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user: FIRUser?, error) in
                if error != nil {
                    print(error!)
                    return
                }
                guard let uid = user?.uid else{return}
            
            //refernece to this user
                self.ref = FIRDatabase.database().reference()
                let UsersRef = self.ref.child("Users").child(uid)
            
            //insert user
                UsersRef.updateChildValues(["user": name, "email": email, "contact": friends], withCompletionBlock: { (err, ref) in
                    if err != nil {
                        print(err!)
                        return
                    }
                })
            })
        }
        
        handleRegister()
        
    }
    @IBAction func loginButton(_ sender: UIButton) {
        print("Login was pressed")
        
        func handleLogin() {
            //wait for user input
            let email: String = "333@gmail.com"
            let password: String = "123456"
            
            //checking the authentication:
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if error != nil {
                    print(error!)
                    return
                }
            })
        //show the user info
            let uid = FIRAuth.auth()?.currentUser?.uid
            self.ref = FIRDatabase.database().reference()
            let UsersRef = self.ref.child("Users").child(uid!)
            UsersRef.observeSingleEvent(of: .value, with: { (snapshot) in
                print(snapshot)
            }, withCancel: nil)
        }

        handleLogin()
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
