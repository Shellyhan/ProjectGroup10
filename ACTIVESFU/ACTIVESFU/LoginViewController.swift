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

       override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self

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
            let alertController = UIAlertController(title: "Oops!", message: "Please enter and email and password.", preferredStyle: .alert)
            let defaulAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaulAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        else
        {
            FIRAuth.auth()?.signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!, completion: { (user,error) in
                if error == nil
                    
                {
                    self.emailTextField.text=""
                    self.passwordTextField.text=""
                }
                else
                {
                    let alertController = UIAlertController(title: "Oops!", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaulAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaulAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                    
                }
            })
            
        }
        
        
<<<<<<< HEAD
        
    }
    @IBAction func accountButton(_ sender: UIButton) {
        if (self.emailTextField.text=="" || self.passwordTextField.text==""){
            let alertController = UIAlertController(title: "Oops!", message: "Please enter and email and password.", preferredStyle: .alert)
            let defaulAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaulAction)
            
            
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            FIRAuth.auth()?.signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!, completion: { (user,error) in
                
                if error == nil
                    
                {
                    self.emailTextField.text=""
                    self.passwordTextField.text=""
                }
                else
                {
                    let alertController = UIAlertController(title: "Oops!", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaulAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(defaulAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            })
        }
        
    }
=======
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
>>>>>>> master
    }
    



