//
//  MainViewControllerHandler.swift
//  ACTIVESFU
//
//  Created by Xue Han on 2017-03-27.
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import CoreLocation
import UserNotifications


import Firebase

//MARK: MainViewController

extension MainViewController: CLLocationManagerDelegate {
    
    //location update:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {}
    
    //setup the target data for work out locations:
    func setupData() {
        
        // check for monitor regions
        if CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            
            //region data: correspond to hte TestLocation.gpx in project folder!!!!
            let title = "gym"
            let coordinate = CLLocationCoordinate2DMake(37.703026, -121.759735) //fake location
            let regionRadius = 300.0
            
            //etup region tracking:
            let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: coordinate.latitude,
                                                                         longitude: coordinate.longitude),
                                          radius: regionRadius, identifier: title)
            
            print("---------------------start to monitor location")
            locationManager.startMonitoring(for: region)
        }
        else {
            
            print("System can't track regions")
        }
    }
    
    // user enter target region:
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("-----enter \(region.identifier)")
        
        //prepare the events list:
        fetchTodayEvent(withCompletionHandler: {})
        //enter time:
        self.timeEnter = Date()
    }
    
    // user exit target region:
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        print("--------exit \(region.identifier)")
        
        //exit time:
        duration = Date().timeIntervalSince(self.timeEnter)
        print("spend \(round(duration)) seconds in \(region.identifier)")
        
        //check if the duration is over half an hour, changed to 10 sec for testing:
        if (duration >= 10) {
            
            // Configure User Notification Center
            configureUserNotificationsCenter()
            // Request Notification Settings
            UNUserNotificationCenter.current().getNotificationSettings { (notificationSettings) in
                switch notificationSettings.authorizationStatus {
                    
                case .notDetermined:
                    
                    self.requestAuthorization(completionHandler: { (success) in
                        guard success else { return }
                        
                        // Schedule Local Notification
                        self.scheduleLocalNotification()
                    })
                case .authorized:
                    
                    // Schedule Local Notification
                    self.scheduleLocalNotification()
                case .denied:
                    
                    print("Application Not Allowed to Display Notifications")
                }
            }
        }
    }
    
    func fetchTodayEvent(withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("here 1")
        
        //reset events array
        events = []
        var eventListforMe = [String]()
        let today = self.formatter.string(from: Date())
        
        let ref = FIRDatabase.database().reference()
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        //filter for events I joined/created:
        ref.child("Participants").child(uid!).observe(.childAdded, with: { (snapshot) in
            
            let EID = snapshot.key
            eventListforMe.append(EID)
            
        },withCancel: nil)
        
        
        //fetch all events in today:
        ref.child("Events").queryOrdered(byChild: "date").queryEqual(toValue: today).observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: Any] {
                
                //check if event is for today:
                let EID = snapshot.key
                
                if eventListforMe.contains(EID) {
                    
                    let eventNow = Event()
                    eventNow.eventID = snapshot.key
                    eventNow.setValuesForKeys(dictionary)
                    self.events.append(eventNow)
                }
            }
            
        },withCancel: nil)
        completionHandler()
    }
    
    func configureUserNotificationsCenter() {
        // Configure User Notification Center
        UNUserNotificationCenter.current().delegate = self
        
        var eventList = [UNNotificationAction]()
        
        for singleEvent in self.events {
            let eventName = singleEvent.title
            
            print("got here \(eventName!)")
            
            eventList.append(UNNotificationAction(identifier: eventName!, title: eventName!, options: []))
        }
        
        
        //set discard option:
        eventList.append(UNNotificationAction(identifier: "discard", title: "Discard", options: []))
        
        let popCategory = UNNotificationCategory(identifier: "pop", actions: eventList, intentIdentifiers: [], options: [])
        
        // Register Category
        UNUserNotificationCenter.current().setNotificationCategories([popCategory])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let ref = FIRDatabase.database().reference()
        let uid = FIRAuth.auth()?.currentUser?.uid
        
        for singleEvent in self.events {
            
            if (response.actionIdentifier == singleEvent.title){
                
                print("got it here")
                
                let ParticipantRef = ref.child("Participants")
                ParticipantRef.child(uid!).updateChildValues([singleEvent.eventID!: round(duration)])
                
                print("updated event duration")
            }
        }
        
        if (response.actionIdentifier == "discard"){
            
            print("discard")
        }
        completionHandler()
    }
    
    
    func requestAuthorization(completionHandler: @escaping (_ success: Bool) -> ()) {
        
        // Request Authorization
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
            
            if let error = error {
                
                print("Request Authorization Failed (\(error), \(error.localizedDescription))")
            }
            completionHandler(success)
        }
    }
    
    func scheduleLocalNotification() {
        
        // Create Notification Content
        let notificationContent = UNMutableNotificationContent()
        
        // Configure Notification Content
        notificationContent.title = "Activity Detected"
        notificationContent.body = "Just finished an activity? Please log your activity record!"
        notificationContent.sound = UNNotificationSound.default()
        
        //set up actions for notification:
        notificationContent.categoryIdentifier = "pop"
        
        // Add Trigger
        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 1.0, repeats: false)
        
        // Create Notification Request
        let notificationRequest = UNNotificationRequest(identifier: "local_notification", content: notificationContent, trigger: notificationTrigger)
        
        // Add Request to User Notification Center
        UNUserNotificationCenter.current().add(notificationRequest) { (error) in
            
            if let error = error {
                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
            }
        }
    }
}

extension MainViewController: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }
}
