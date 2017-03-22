//
//  LocationViewController.swift
//  Developed by Ryan Brown
//
//  Using the coding standard provided by eure: github.com/eure/swift-style-guide
//
//  Tracks the user location, shows their location on a map.
//
//  Bugs:
//
//
//
//  Changes:
//
//
//
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.
//  Credits to http://theswiftguy.com/index.php/2016/09/28/how-to-get-the-users-current-location-in-xcode-8-swift-3-0/

import UIKit
import MapKit
import CoreLocation
import Firebase

class LocationViewController: UIViewController, CLLocationManagerDelegate {
    
    
    // MARK: Internal
    
    @IBOutlet weak var map: MKMapView!
    let manager = CLLocationManager()
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations[0]
        
        // Span deals how far the map is zoomed in
        let span:MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        
        let myLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        
        let region:MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        map.setRegion(region, animated: true)
        
        self.map.showsUserLocation = true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.delegate = self
        // Possibly change desiredAccuracy to something else in case it slow the app down too much (maybe within 10 meters or 100 meters or something)
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
