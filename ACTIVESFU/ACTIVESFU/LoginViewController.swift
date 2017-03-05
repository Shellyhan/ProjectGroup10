//
//  LoginViewController.swift
//  ACTIVESFU
//
//  Created by Bronwyn Biro on 2017-02-27.
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var ref: FIRDatabaseReference!
    
    
       override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        ref = FIRDatabase.database().reference()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.returnKeyType = UIReturnKeyType.done
        self.emailTextField.keyboardType = UIKeyboardType.emailAddress
        return true
    }
  
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func loginButton(_ sender: UIButton) {
        if (self.emailTextField.text=="" || self.passwordTextField.text==""){
            //shelly's code
            print("Login was pressed")
            
            
            //carber's code
            let alertController = UIAlertController(title: "Oops!", message: "Please enter and email and password.", preferredStyle: .alert)
            let defaulAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaulAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        else
        {
            func handleLogin() {
                //wait for user input
                //                let email: String = "333@gmail.com"
                //                let password: String = "123456"
                
                //checking the authentication:
                FIRAuth.auth()?.signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!, completion: { (user, error) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    else{
                        print("login successful")
                        let loggedInScene = self.navigationController?.storyboard?.instantiateViewController(withIdentifier: "mainmenuVC_ID") as! MainViewController
                        self.navigationController?.pushViewController(loggedInScene, animated: true)
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
   }
}
    



