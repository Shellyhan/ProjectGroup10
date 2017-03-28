//
//  ProfileViewController.swift
//  Developed by Ryan Brown
//
//  Using the coding standard provided by eure: github.com/eure/swift-style-guide
//
//  Shows the user's basic info and survey results. The user will be able to change their photo and name.
//
//  Bugs:
//
//  Profile pictures aren't deleted but replaced
//  When changing photos it takes a while for cache to update, will see old profile for a few seconds
//
//  Changes:
//
//
//
//
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.
// Credits to: https://github.com/aburhan/Swift-Firebase-Profile

import UIKit
import Firebase

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    // Variables
    let storageRef = FIRStorage.storage().reference()
    let databaseRef = FIRDatabase.database().reference()
    let userDetails = User()
    
    var originalUsername: String?
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var activityContainer: UIView = UIView()
    var loadingView: UIView = UIView()
    
    // Outlets
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameText: UITextField!
    
    
    // Buttons

    //TODO: View stats for the month
    @IBAction func viewStats(_ sender: UIButton) {
    }

    @IBAction func editSurvey(_ sender: UIButton) {
        
        //Gets the reference to the user's uid
        let userID = FIRAuth.auth()?.currentUser?.uid
        let referenceToUserID = databaseRef.child("Users").child(userID!)
        
        referenceToUserID.observeSingleEvent(of: .value, with: { (snapshot) in
        
            //eg. Users/Foo/name, email, DaysAvail, Time, etc - the children in the user's uid
            for restCategory in snapshot.children.allObjects as! [FIRDataSnapshot] {
                
                //Take advantage of the fact that only the survey questions will have children values
                if restCategory.hasChildren() && restCategory.key != "Buddies" {
                    
                    //eg. DaysAvail
                    let surveyCategoryToDelete = restCategory.key
                    
                    //eg. Users/Foo/DaysAvail
                    let userReferenceToCategoryToDelete = referenceToUserID.child(surveyCategoryToDelete)
                    
                    userReferenceToCategoryToDelete.observeSingleEvent(of: .value, with: { (snapshot) in //Nested loop
                     
                        //eg. Users/Foo/DaysAvail/Mon, tues, wed,... - the nested children in the user's uid survey categories
                        for restKeys in snapshot.children.allObjects as! [FIRDataSnapshot] {
                            
                            //eg. DaysAvail/Mon/Foo uid - we want to delete the values in the survey answer arrays
                            let pathToDelete = self.databaseRef.child("\(surveyCategoryToDelete)").child("\(restKeys.key)").child(userID!)
                                                        
                            //Remove the values in the survey arrays
                            pathToDelete.removeValue()
                            //Remove the values in the user's array as well
                            userReferenceToCategoryToDelete.child("\(restKeys.key)").removeValue()
                        }
                    })
                }
            }
        })
        
        //Redo survey
        let surveyController = QuestionController()
        surveyController.didEditProfile = 1
        let navController = UINavigationController(rootViewController: surveyController)
        self.present(navController, animated: true, completion: nil)
    }

    @IBAction func saveChanges(_ sender: Any) {
        saveChanges()
    }

    @IBAction func uploadImage(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(picker, animated: true, completion: nil)
    }

    // Functions
    func setupProfile() {
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.clipsToBounds = true
        
        usernameText.textAlignment = .center
        
        if let uid = FIRAuth.auth()?.currentUser?.uid{
            databaseRef.child("Users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dict = snapshot.value as? [String: AnyObject] {
                    self.usernameText.text = dict["user"] as? String
                    if let profileImageURL = dict["pic"] as? String {
                    
                        self.profileImage.loadImageUsingCacheWithUrlString(urlString: profileImageURL)
                    }
                }
            })
            
        }
    }
    
    // This function allows you to change the profile image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImageFromPicker = editedImage
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker{
            profileImage.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func saveChanges(){
        
        showActivityIndicator(uiView: self.view)
        
        let imageName = NSUUID().uuidString
        let storedImage = storageRef.child("profileImages").child("\(imageName).png")
        
        //stop user interaction while profile picture is updated
        
        if let uploadData = UIImagePNGRepresentation(self.profileImage.image!){
            
            storedImage.put(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error!)
                    return
                }
                storedImage.downloadURL(completion: { (url, error) in
                    if error != nil {
                        
                        print(error!)
                        return
                    }
                    if let urlText = url?.absoluteString {
                        
                        self.databaseRef.child("Users").child((FIRAuth.auth()?.currentUser?.uid)!).updateChildValues(["pic" : urlText, "user": self.usernameText.text!], withCompletionBlock: { (error, ref) in
                            if error != nil{
                                print(error!)
                                return
                            }
                            //stop activity indicator once done
                            self.hideActivityIndicator(uiView: self.view)
                        })
                    }
                })
            })
        }
    }
    
        
    override func viewDidLoad() {
        
        super.viewDidLoad()
        print(usernameText.text!)
        usernameText.delegate = self
        setupProfile()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.text == "" {
            usernameText.text = originalUsername
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        originalUsername = textField.text
        textField.returnKeyType = .done
    }

}
