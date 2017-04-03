//
//  ProfileStatsViewController.swift
//  ACTIVESFU
//
//  Created by CoolMac on 2017-04-02.
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.
//

import UIKit

import Firebase
import Charts

class ProfileStatsViewController: UIViewController {

    @IBOutlet weak var floatingpoint: UILabel!
    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var totalBuddies: UILabel!
    @IBOutlet weak var totalActivityTime: UILabel!

    let activities = ["Badminton", "Basketball", "Climbing", "Cycling", "Hiking", "Gym", "Tennis", "Yoga", "Other"]
    let referenceToEventDatabase = FIRDatabase.database().reference().child("Participants")
    let currentUser = FIRAuth.auth()?.currentUser?.uid
    var activityMinutesTotal = Array(repeating: 0.0, count: 9)

    
    func displayNumOfBuddies () {
        
        var numBuddies = 0
        
        FIRDatabase.database().reference().child("Users").child(currentUser!).child("Buddies").observeSingleEvent(of: .value, with: { (buddiesSnap) in
            
            for userBuddies in buddiesSnap.children.allObjects as! [FIRDataSnapshot] {
                
                //if the value is 1, then the user is blocked
                if userBuddies.value as? Int == 0 {
                    
                    numBuddies = numBuddies + 1
                }
            }
            self.totalBuddies.text = "\(numBuddies) buddies"
        })
    }
    
    //TODO: separate activity times and display in a chart
    
    func displayUserTimesTotal () {
        
        var totalTime = 0.0
        
        referenceToEventDatabase.child(currentUser!).observeSingleEvent(of: .value, with: { (timeSnap) in
            
            for individualTimes in timeSnap.children.allObjects as! [FIRDataSnapshot] {
                
                totalTime += individualTimes.value as! Double
                
            }
            
            totalTime = Double(totalTime / 60).roundTo(places: 2)
            
            self.totalActivityTime.text = "\(totalTime) minutes"
        })
    }
    
    //TODO: Go through the user's participating events (hard code different titles)
    //TODO: For each event, add the minutes
    
    func gatherEventIDs(completion: @escaping (Array<Any>) -> ()) {
        
        var eventIDArray = Array<Any>()
        //var eventIDsvalue = Array<Any>()
        
        
        referenceToEventDatabase.child(currentUser!).observeSingleEvent(of: .value, with: { (snapshot) in

            for eventIDs in snapshot.children.allObjects as! [FIRDataSnapshot] {
                
                eventIDArray.append(eventIDs.key)

                //minutes.append(eventIDs.value)
                
                FIRDatabase.database().reference().child("Events").child("\(eventIDs.key)").child("title").observeSingleEvent(of: .value, with: { (activitysnapshot) in
                    
                    //print(activitysnapshot.value!)
                    
                    switch activitysnapshot.value as! String {
                        
                    case "Badminton":
                        self.activityMinutesTotal[0] += eventIDs.value as! Double
                        
                    case "Basketball":
                        self.activityMinutesTotal[1] += eventIDs.value as! Double
                        
                    case "Climbing":
                        self.activityMinutesTotal[2] += eventIDs.value as! Double
                        
                    case "Cycling":
                        self.activityMinutesTotal[3] += eventIDs.value as! Double
                        
                    case "Hiking":
                        self.activityMinutesTotal[4] += eventIDs.value as! Double
                        
                    case "Gym":
                        self.activityMinutesTotal[5] += eventIDs.value as! Double
                        
                    case "Tennis":
                        self.activityMinutesTotal[6] += eventIDs.value as! Double
                    case "Yoga":
                        self.activityMinutesTotal[7] += eventIDs.value as! Double
                        
                    case "Other":
                        self.activityMinutesTotal[8] += eventIDs.value as! Double
                        
                    default: break
                    }
                    if eventIDs.key == eventIDArray.last as! String {
                        
                        //print(self.activityMinutesTotal)
                        completion(self.activityMinutesTotal)
                    }

                })
            }
            
        })
        
    }
    

    func updateChartData()  {
        
        let chart = pieChartView
        // 2. generate chart data entries
        
        gatherEventIDs { (activityMinutesTotal) in
            
            //print(activityMinutesTotal)
           // let testArray = [18.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 23.4, 20.0]
            var entries = [PieChartDataEntry]()
            for (index, value) in activityMinutesTotal.enumerated() {
                
                let entry = PieChartDataEntry()
                if value as! Double != 0.0  {

                    entry.y = ((value as! Double) / 60).roundTo(places: 2)
                    entry.label = self.activities[index]
                    entries.append(entry)
                }
            }
            
            // 3. chart setup
            let set = PieChartDataSet( values: entries, label: nil)

            var colors: [UIColor] = []
            
            for _ in 0..<activityMinutesTotal.count {
                
                let red = Double(arc4random_uniform(156))
                let green = Double(arc4random_uniform(156))
                let blue = Double(arc4random_uniform(156))
                let color = UIColor(red: CGFloat(red/255), green: CGFloat(green/255), blue: CGFloat(blue/255), alpha: 1)
                colors.append(color)
            }
            set.colors = colors
            let data = PieChartData(dataSet: set)
            chart?.legend.textColor = UIColor.white
            chart?.data = data
            chart?.noDataText = "No data available"
            // user interaction
            chart?.isUserInteractionEnabled = true
            
            let d = Description()
            d.text = "ACTIVESFU"
            d.textColor = UIColor.white
            chart?.chartDescription = d
            chart?.centerText = "Activities in minutes"
            chart?.holeRadiusPercent = 0.4
            chart?.transparentCircleColor = UIColor.clear
            self.view.addSubview(chart!)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateChartData()
        displayNumOfBuddies()
        displayUserTimesTotal()

        // Do any additional setup after loading the view.
    }
}

extension Double {
    
    func roundTo(places: Int) -> Double {
        
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
