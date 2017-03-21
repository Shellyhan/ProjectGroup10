//
//  CalendarUITest.swift
//  ACTIVESFU
//
//  Created by CoolMac on 2017-03-20.
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.
//

import XCTest

class CalendarUITest: UITestCase {
    
    func testCurrentDateHighlightIsCurrentDate() {
        app.buttons["Calendar"].tap()

        let todaysDateInApp = app.collectionViews.staticTexts[":)"]
        todaysDateInApp.tap()
        
        //if the current date text doesn't exist, that means it's replaced by a smiley
        
        let date = Date()
        let calendar = Calendar.current
        
        let day = calendar.component(.day, from: date)
        
        let dayString = String(day)
        
        XCTAssertNotEqual(todaysDateInApp.label, dayString)
        
    }
    
    func testClickingDateWithEventShowsEvent() {
        
        app.buttons["Calendar"].tap()
        
        
        app.collectionViews.staticTexts["23"].tap()
        
        let tablesQuery = app.tables
        let count = tablesQuery.cells.count
        
        XCTAssert(count > 0)
        
    }
    
    func testCreateNewEvent() {
        
        app.buttons["Calendar"].tap()
        
        app.collectionViews.staticTexts["22"].tap()
        
        let tablesQuery = app.tables
        var count = tablesQuery.cells.count
        
        XCTAssert(count == 1)
        
        app.buttons["Create New"].tap()
        
        let CreateAnEventViewExists = app.staticTexts["Create an event"]
        
        waitForElementToAppear(CreateAnEventViewExists)
        XCTAssert(CreateAnEventViewExists.exists)
        
        
        app.pickerWheels["Badminton"].adjust(toPickerWheelValue: "Tennis")

        app.pickerWheels["Gym"].adjust(toPickerWheelValue: "Field")
        
    
        
        app.buttons["CREATE"].tap()
        
        app.alerts["Create New Event"].buttons["OK"].tap()
        
        count = tablesQuery.cells.count
        XCTAssert(count == 2)
    }
    
    func testEditEventWorks() {
        
        app.buttons["Calendar"].tap()
        
        app.collectionViews.staticTexts["22"].tap()
        
        var eventName = app.tables.staticTexts["Tennis"]
        XCTAssert(eventName.exists)
        
        eventName.tap()
        
        let eventInfoView = app.staticTexts["Event:   Tennis"]
        waitForElementToAppear(eventInfoView)
        XCTAssert(eventInfoView.exists)
        
        let editButton = app.buttons["Edit"]
        
        XCTAssert(editButton.exists)
        
        editButton.tap()
        
        app.pickerWheels["Badminton"].adjust(toPickerWheelValue: "Hiking")
        app.buttons["Update"].tap()
        
        app.alerts["Create New Event"].buttons["OK"].tap()
        let editInfoView = app.tables.staticTexts["Hiking"]
        
        app.navigationBars.buttons["Back"].tap()

        XCTAssert(editInfoView.exists) //Event doesn't update until you deselect and reselect - BUG
    }

    
    func testDeleteEventWorks() {
        
        app.buttons["Calendar"].tap()
        app.collectionViews.staticTexts["22"].tap()
        
        let tablesQuery = app.tables
        var count = tablesQuery.cells.count
        
        XCTAssert(count == 2)
        
        app.tables.staticTexts["Tennis"].tap()
        
        let eventInfoView = app.staticTexts["Event:   Hiking"]
        waitForElementToAppear(eventInfoView)
        XCTAssert(eventInfoView.exists)
        
        let removeButton = app.buttons["Remove"]
        
        XCTAssert(removeButton.exists)
        
        removeButton.tap()
        
        app.alerts["Delete Event"].buttons["OK"].tap()
        
        count = tablesQuery.cells.count
        XCTAssert(count == 1) //fail since we need to update the calendar afterwards - BUG
        
    }
    func testSearchWorks() { //this will 'fail' since search isn't working
        app.buttons["Calendar"].tap()
        
        let searchSearchField = app.searchFields["Search"]
        searchSearchField.tap()
        searchSearchField.typeText("Tennis")
        app.buttons["Morning"].tap()
        app.buttons["Afternoon"].tap()
        app.buttons["Evening"].tap()
        app.buttons["Cancel"].tap()
        
        
    }
    
    
    func testCalendarSwipes() {
        app.buttons["Calendar"].tap()
        
        let element = app.children(matching: .window).element(boundBy: 0).children(matching: .other).element
        element.swipeLeft()
        XCTAssert(app.collectionViews.staticTexts["2017 APRIL"].exists)
        element.swipeLeft()
        XCTAssert(app.collectionViews.staticTexts["2017 MAY"].exists)
        element.swipeRight()
        XCTAssert(app.collectionViews.staticTexts["2017 APRIL"].exists)
        
    }
    
}
