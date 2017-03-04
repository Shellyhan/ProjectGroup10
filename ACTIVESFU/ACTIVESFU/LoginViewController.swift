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
        
        //looking for entering:
        //let email = emailTextField.text
        //let passward  = passwardTextField.text
        //let username = nameTextField.text
        let email: String = "111@gmail.com"
        let passward: String = "123456"
        let username: String = "Shelly"
        
        //Create new authentication and insert to DB:
        FIRAuth.auth()?.createUser(withEmail: email, password: passward, completion: { (user: FIRUser?, error) in
            if error != nil {
            print("error")
            return
            }
            guard let uid = user?.uid else{return}
            
            //refernece to this user
            self.ref = FIRDatabase.database().reference()
            let UsersRef = self.ref.child("Users").child(uid)
            
            //insert user
            UsersRef.updateChildValues(["user": username, "email": email], withCompletionBlock: { (err, ref) in
                if err != nil {
                    print("error")
                    return
                }
            })
        })
        
    }
    @IBAction func loginButton(_ sender: UIButton) {
        print("Login was pressed")
        
        //looking for entering:
        //let email = emailTextField.text
        //let passward  = passwardTextField.text
        //let username = nameTextField.text
        let email: String = "111@gmail.com"
        let passward: String = "123456"
        
        //checking the authentication:
        FIRAuth.auth()?.signIn(withEmail: email, password: passward, completion: { (user, error) in
            if error != nil {
                print("error")
                return
            }
        })
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
