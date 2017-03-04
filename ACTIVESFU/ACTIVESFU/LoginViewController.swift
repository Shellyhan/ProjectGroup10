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

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    }
    



