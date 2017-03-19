//
//  CreateEventControllertest.swift
//  
//
//  Created by Bronwyn Biro on 2017-03-08.
//
//

import XCTest

class CreateEventControllertest: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launch()
    }
    
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        app.terminate()
    }
    
    func testNavigateToCreate(){
        let nav = app.buttons["Calendar"]
        nav.press(forDuration: 0.5)
    }
    /*
    func testExample() {
        
        let eventTextField = app.textFields["eventTextField"]
        eventTextField.tap()
        eventTextField.typeText("Gym test")
 
    }
   */
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
