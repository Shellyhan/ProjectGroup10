//
//  LoginViewController.swift
//  Developed by Carber Zhang, Nathan Cheung, Bronwyn Biro
//
//  Using the coding standard provided by eure: github.com/eure/swift-style-guide
//
//  The view controller the user sees when he is not logged into his account or starts the app
//  for the first time. User is able to register using email and a password and data will be saved
//  in Firebase.
//
//  Bugs:
//
//
//
//  Changes:
//  Allowed keyboard to be dismissed when pressing 'done'
//  Changed transition from navigate to dismiss
//
//
//
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.

import UIKit

import Firebase


//MARK: LoginViewController


class LoginViewController: UIViewController, UITextFieldDelegate {
    
    
    //MARK: Internal

    
    @IBOutlet weak var toggleLoginRegister: UISegmentedControl!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginRegisterLabel: UILabel!

    @IBOutlet weak var passLine: UIImageView!
    @IBOutlet weak var nameIcon: UIImageView!
    @IBOutlet weak var passIcon: UIImageView!
    @IBOutlet weak var emailIcon: UIImageView!
    
    var firebaseReference: FIRDatabaseReference!
    
    @IBAction func toggleLoginRegister(_ sender: UISegmentedControl) {

        if sender.selectedSegmentIndex == 0 {
            
            nameTextField.isHidden = true
            passLine.isHidden = true
            nameIcon.isHidden = true
            
            emailTextField.frame.origin.y = 305
            emailIcon.frame.origin.y = 305
            
            passwordTextField.frame.origin.y = 344
            passIcon.frame.origin.y = 344
            
            loginRegisterLabel.text = "LOGIN"
        }
        else {
            
            nameTextField.isHidden = false
            passLine.isHidden = false
            nameIcon.isHidden = false
            
            emailTextField.frame.origin.y = 344
            emailIcon.frame.origin.y = 344
            
            passwordTextField.frame.origin.y = 386
            passIcon.frame.origin.y = 387
            
            loginRegisterLabel.text = "REGISTER"
        }
    }
    

    
//    @IBAction func loginButton(_ sender: UIButton) {
//
//
//        if (self.emailTextField.text=="" || self.passwordTextField.text=="") {
//            
//            print("Login was pressed")
//            
//            let alertController = UIAlertController(title: "Oops!", message: "Please enter and email and password.", preferredStyle: .alert)
//            let defaulAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//            alertController.addAction(defaulAction)
//            
//            self.present(alertController, animated: true, completion: nil)
//        }
//        else {
//            
//            handleLogin()
//        }
//    }
    
    @IBAction func loginRegisterButton(_ sender: UIButton) {
        
        if toggleLoginRegister.selectedSegmentIndex == 1 {
            
            if (self.emailTextField.text=="" || self.passwordTextField.text=="") {
                
                let alertController = UIAlertController(title: "Oops!", message: "Please enter and email and password.", preferredStyle: .alert)
                let defaulAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertController.addAction(defaulAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
            else {
                
                handleRegister()
            }
        }
        else {
            
            handleLogin()
            print("The toggle is set to Login")
        }
    }
    
    func segueToSurvey(){
        
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.black]

        
        let surveyController = QuestionController()
        let navController = UINavigationController(rootViewController: surveyController)
        self.present(navController, animated: true, completion: nil)
    }
    
    func handleLogin() {
        
        //checking the authentication:
        FIRAuth.auth()?.signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!, completion: { (user, error) in
            if error != nil {
                
                print(error!)
                return
            }
            else{
                
                print("login successful")
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    func handleRegister() {
        
        let name = nameTextField.text
        
        FIRAuth.auth()?.createUser(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!, completion: { (user: FIRUser?, error) in
            if error != nil {
                
                print(error!)
                return
            }
            guard let userUID = user?.uid
            else {
                return
            }
            
            self.firebaseReference = FIRDatabase.database().reference()
            let userReferenceInDatabase = self.firebaseReference.child("Users").child(userUID)
            
            //insert user
            let values = ["user": name, "email": self.emailTextField.text!]
            userReferenceInDatabase.updateChildValues(values, withCompletionBlock: { (err, ref) in
                
                if err != nil {
                    print(err!)
                    return
                }
            })
            
                print("Create account successful")
                self.segueToSurvey()
            })
    }
    
    
    //MARK: UIViewController
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        emailTextField.delegate = self
        nameTextField.delegate = self
        passwordTextField.delegate = self
        firebaseReference = FIRDatabase.database().reference()
    }
    
    
    //MARK: UITextFieldDelegate
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        textField.returnKeyType = UIReturnKeyType.done
        self.emailTextField.keyboardType = UIKeyboardType.emailAddress
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }

//fileprivate func registerUserIntoDatabaseWithUID(_ uid: String, values: [String: AnyObject]) {
//    
//    let referenceToDatabase = FIRDatabase.database().reference()
//    let usersReference = referenceToDatabase.child("users").child(uid)
//    let userUsername: String = "shelly"
//        //let userFriends: Array = ["7PT0C9flfDM3RcZtdcHURzySlaJ2", "orQY3pNQxJa1h5RcBa1QrjKblQg2"]//dummy users
//
//    FIRAuth.auth()?.createUser(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!, completion: { (user: FIRUser?, error) in
//        if error != nil {
//                
//            print(error!)
//            return
//        }
//        guard let userUID = user?.uid
//        else {
//                    
//        return
//        }
//            
//    self.firebaseReference = FIRDatabase.database().reference()
//    let userReferenceInDatabase = self.firebaseReference.child("Users").child(userUID)
//            
//    //insert user
//    userReferenceInDatabase.updateChildValues(["user": userUsername, "email": self.emailTextField.text!], withCompletionBlock: { (err, ref) in
//        if err != nil {
//                    
//            print(err!)
//            return
//        }
//        print("Create account successful")
//        self.segueToSurvey()
//    })
//    })
//}
}

    
//    fileprivate func registerUserIntoDatabaseWithUID(_ uid: String, values: [String: AnyObject]) {
//        let ref = FIRDatabase.database().reference()
//        let usersReference = ref.child("users").child(uid)
//        
//        usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
//            
//            if err != nil {
//                print(err!)
//                return
//            }
//            
//            let user = User()
//            //this setter potentially crashes if keys don't match
//            user.setValuesForKeys(values)
//            self.dismiss(animated: true, completion: nil)
//        })
//    }


    



