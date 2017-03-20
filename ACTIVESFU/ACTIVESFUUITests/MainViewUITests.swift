//
//  MainViewUITests.swift
//  ACTIVESFU
//
//  Created by CoolMac on 2017-03-19.
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
        let viewBuddiesHeader = app.navigationBars["View Buddies"]
        waitForElementToAppear(viewBuddiesHeader)
        XCTAssert(viewBuddiesHeader.exists)
        
    }
    
    func testGoTo
    
}
