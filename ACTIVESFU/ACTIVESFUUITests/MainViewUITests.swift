//
//  MainViewUITests.swift
//  Developed by Nathan Cheung
//
//  UI tests to make sure the main view controller is connected to the correct views
//
//
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.
//

import XCTest

class MainViewUITests: UITestCase {
        
    func testGoToCalendar() {
        
        app.buttons["Calendar"].tap()
        
        let calendarHeader = app.navigationBars["Calendar"]
        waitForElementToAppear(calendarHeader)
        XCTAssert(calendarHeader.exists)
    }
    
    func testGoToViewBuddies() {
        
        app.buttons["View Buddies"].tap()

        
        let viewBuddiesHeader = app.tables.staticTexts["View Buddies"]
        
        waitForElementToAppear(viewBuddiesHeader)
        XCTAssert(viewBuddiesHeader.exists)
        
    }
    
    func testGoToFindBuddies() { //this will fail because the view goes to view buddies for some reason
        
        app.buttons["Find a Buddy"].tap()
        
        let findABuddyView = app.staticTexts["Shake your phone"]
        
        waitForElementToAppear(findABuddyView)
        XCTAssert(findABuddyView.exists)
    }
    
    func testGoToProfile() { //integrate this test once profile setup is complete
        
        
    }
    
    func testGoToLocation() { //integrate this test once location is complete
        
        
    }
    
}
