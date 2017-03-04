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
    @IBOutlet weak var EmailField: UITextField!
    @IBOutlet weak var PasswordField: UITextField!
       override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func loginAction(_ sender: Any)
    {
        if (self.EmailField.text=="" || self.PasswordField.text==""){
            let alertController = UIAlertController(title: "Oops!", message: "Please enter and email and password.", preferredStyle: .alert)
            let defaulAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaulAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        else
        {
            FIRAuth.auth()?.signIn(withEmail: self.EmailField.text!, password: self.PasswordField.text!, completion: { (user,error) in
                if error == nil
                    
                {
                    self.EmailField.text=""
                    self.PasswordField.text=""
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
    @IBAction func CreateAccountAction(_ sender: Any) {
        if (self.EmailField.text=="" || self.PasswordField.text==""){
            let alertController = UIAlertController(title: "Oops!", message: "Please enter and email and password.", preferredStyle: .alert)
            let defaulAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaulAction)

            
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            FIRAuth.auth()?.signIn(withEmail: self.EmailField.text!, password: self.PasswordField.text!, completion: { (user,error) in

                if error == nil
                
                {
                    self.EmailField.text=""
                    self.PasswordField.text=""
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
