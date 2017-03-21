//
//  ViewBuddiesViewUITest.swift
//  ACTIVESFU
//
//  Created by xiangge zhang on 2017-03-20.
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.
//

import XCTest

class BuddiesViewUITests: UITestCase {

    func testButtonAndTable(){
        
        //go to View Buddies
        
        app.buttons["x icon"].tap()
        
        app.segmentedControls.buttons["Login"].tap()
        
        let emailTextField = app.textFields["Email"]
        emailTextField.tap()
        emailTextField.typeText("testmail@gmail.com\n")
        
        
        let passwordTextfield = app.secureTextFields["Password"]
        passwordTextfield.tap()
        passwordTextfield.typeText("123abc\n")
        
        app.staticTexts["LOGIN"].tap()

        app.buttons["View Buddies"].tap()
        
        //check if the number of buttons and tables is correct
        
        XCTAssertEqual(app.tables.count, 1)
        XCTAssertEqual(app.buttons.count, 2)
        
        //check if the number of output raws from database is correct
        
        let table = app.tables.element(boundBy: 0)
        XCTAssertEqual(table.cells.count, 18)

        //check if user can chat with buddies
        
        let firstcell = app.tables.cells.element(boundBy: 0).staticTexts.element(boundBy: 0)
        firstcell.tap()
        
        app.buttons["Back"].tap()
    }
    
}
