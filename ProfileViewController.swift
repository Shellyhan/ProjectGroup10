// *** READ: All login/logout related code is commented out
// because the tutorial I was following had its own login
// system in place. Still needs to be connected to ours.
//
//  ProfileViewController.swift
//  userProfile
//
//  Created by Ryan Brown on 2017-03-16.
//  Copyright © 2017 Ryan Brown. All rights reserved.
//
// Credits to: https://github.com/aburhan/Swift-Firebase-Profile

import UIKit
import Firebase

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // Variables
    let storageRef = FIRStorage.storage().reference()
    let databaseRef = FIRDatabase.database().reference()
    
    
    // Outlets
    @IBOutlet weak var profileImage: UIImageView!
    
    @IBOutlet weak var usernameText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Logs the user out if they're not logged in
      //  if FIRAuth.auth()?.currentUser?.uid == nil{
     //       logout()
     //   }
        
        setupProfile()
    }
    
    // Buttons
    @IBAction func changeUsername(_ sender: Any) {
    }
    
    @IBAction func editInfo(_ sender: Any) {
        usernameText.isUserInteractionEnabled = true
    }
    
    @IBAction func editSurvey(_ sender: Any) {
    }
    
    @IBAction func logoutButton(_ sender: Any) {
  //      logout()
    }
    
    @IBAction func saveChanges(_ sender: Any) {
        saveChanges()
        usernameText.isUserInteractionEnabled = false
        usernameText.textAlignment = .center
    }
    
    @IBAction func uploadImage(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    // Functions
    func setupProfile(){
        profileImage.layer.cornerRadius = profileImage.frame.size.width/2
        profileImage.clipsToBounds = true
        
        if let uid = FIRAuth.auth()?.currentUser?.uid{
        databaseRef.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String: AnyObject]{
                self.usernameText.text = dict["username"] as? String
                if let profileImageURL = dict["pic"] as? String{
                    let url = URL(string: profileImageURL)
                    URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                        if error != nil{
                            print(error!)
                            return
                        }
                        DispatchQueue.main.async {
                            self.profileImage?.image = UIImage(data: data!)
                        }
                    }).resume()
                }
            }
        })
        
        }
    }
    
    /*
    func logout(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "Login")
        present(loginViewController, animated: true, completion: nil)
    }
    */
    
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
        let imageName = NSUUID().uuidString
        let storedImage = storageRef.child("profileImages").child(imageName)
        
        if let uploadData = UIImagePNGRepresentation(self.profileImage.image!){
            storedImage.put(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil{
                    print(error!)
                    return
                }
                storedImage.downloadURL(completion: { (url, error) in
                    if error != nil{
                        print(error!)
                        return
                    }
                    if let urlText = url?.absoluteString{
                        self.databaseRef.child("users").child((FIRAuth.auth()?.currentUser?.uid)!).updateChildValues(["pic" : urlText], withCompletionBlock: { (error, ref) in
                            if error != nil{
                                print(error!)
                                return
                            }
                        })
                    }
                })
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

