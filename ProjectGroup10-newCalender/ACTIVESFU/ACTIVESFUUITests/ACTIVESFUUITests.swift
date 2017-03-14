//
//  ACTIVESFUUITests.swift
//  ACTIVESFUUITests
//
//  Created by Bronwyn Biro on 2017-02-03.
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.
//

import XCTest

class ACTIVESFUUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUp() {
        
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        app.terminate()
    }
    
    
    func testIfElementExists() {
        
        XCTAssert(app.staticTexts["ACTIVE SFU"].exists)
    }
    
    func testNavigatetoViewBuddies(){
        
        app.buttons["View Buddies"].tap()
        
    }
    
    func testLoginFromMain(){
        
      //  app.buttons["logout"].tap()
        
        let textField = app.textFields["Email"]
        textField.tap()
        textField.typeText("testmail@gmail.com")
        textField.typeText("\n")
        
        let passtextField = app.textFields["Password"] //Bug - Password isn't named password
        passtextField.tap()
        textField.typeText("123abc")
        textField.typeText("\n")
        
        app.buttons["LOGIN"].tap()
    }
    
    
    func testExample() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
}
