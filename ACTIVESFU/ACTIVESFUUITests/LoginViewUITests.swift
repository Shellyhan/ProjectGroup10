//
//  ACTIVESFUUITests.swift
//  ACTIVESFUUITests
//
//  Created by Bronwyn Biro on 2017-02-03.
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.
//

import XCTest

class LoginViewUITests: UITestCase {

    func testLogoutFromMain(){
        
        app.buttons["x icon"].tap()
        XCTAssert(app.staticTexts["REGISTER"].exists)
    }
    
    func testLoginSwitch() {
        
        XCTAssert(app.staticTexts["REGISTER"].exists)
        
        app.segmentedControls.buttons["Login"].tap()
        
        XCTAssert(app.staticTexts["LOGIN"].exists)
    }
    
    //Tests if toggling login and register will clear the textfields
    func testToggleLoginRegisterTextFieldsClear() {
        
        let toggleLogin = app.segmentedControls.buttons["Login"]
        let toggleRegister = app.segmentedControls.buttons["Register"]
        
        let emailTextField = app.textFields["Email"]
        emailTextField.tap()
        emailTextField.typeText("testmail@gmail.com \n")
        
        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("123abc")
        
        toggleLogin.tap()
        toggleRegister.tap()
        
        XCTAssertEqual(emailTextField.value as! String, "")
        XCTAssertEqual(passwordSecureTextField.value as! String, "")
        
    }
    
    func testCanEditNameFieldWhenLogin() {
        
        let nameField = app.textFields["Name"]
        app.segmentedControls.buttons["Login"].tap()
        
        XCTAssertFalse(nameField.exists, "NameField exists and can be modified")
    }
    
    func testLoginErrorNoEmailOrPass() {
        
        app.segmentedControls.buttons["Login"].tap()
        app.staticTexts["LOGIN"].tap()
        
        XCTAssert(app.alerts.element.staticTexts["Please enter an email and password."].exists)
        
        app.alerts["Oops!"].buttons["OK"].tap()
        
    }
    
    func testRegisterNoName() {
        
        app.textFields["Email"].tap()
        app.textFields["Email"].typeText("wowie123@wow.com\n")
        
        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText("qqqqqq")
        
        app.staticTexts["REGISTER"].tap()
        
        XCTAssert(app.alerts.element.staticTexts["Please enter your name in the name field."].exists)
        app.alerts["Oops!"].buttons["OK"].tap()
    }
    
    func testsBadEmailFormats() {
        

        //test if bad email format for register
        
        app.textFields["Name"].tap()
        app.textFields["Name"].typeText("Foo \n")
        
        app.textFields["Email"].tap()
        app.textFields["Email"].typeText("wowie123@wow\n")
        
        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText("qqqqqq")
        
        app.staticTexts["REGISTER"].tap()
        
        app.alerts["Oops!"].buttons["OK"].tap()
    
    }
    
    func testPassTooShort() {
        //test if pass is too short
        
        app.textFields["Name"].tap()
        app.textFields["Name"].typeText("Foo \n")
        
        app.textFields["Email"].tap()
        app.textFields["Email"].typeText("wowie123@wow\n")
        
        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText("qqq")
        
        app.staticTexts["REGISTER"].tap()

        
        app.alerts["Oops!"].buttons["OK"].tap()
    }
    
    func testEmailAlreadyInUse() {
    
        //test if email already in Use
        
        app.textFields["Name"].tap()
        app.textFields["Name"].typeText("Foo \n")
        
        app.textFields["Email"].tap()
        app.textFields["Email"].typeText("testmail@gmail.com\n")
        
        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText("qqqqqq")
        
        app.staticTexts["REGISTER"].tap()

        app.alerts["Oops!"].buttons["OK"].tap()
    }
    
    func testLoginEmailFormatBad() {
    
        //test if email bad format for login
        
        app.segmentedControls.buttons["Login"].tap()
        
        app.textFields["Email"].tap()
        app.textFields["Email"].typeText("testmail@gm\n")
        
        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText("qqqqqq")
        
        app.staticTexts["LOGIN"].tap()
        
        app.alerts["Oops!"].buttons["OK"].tap()
    }
    
    func testLoginPassIsWrong() {
        //test wrong password for login
        
        app.segmentedControls.buttons["Login"].tap()
        
        app.textFields["Email"].tap()
        app.textFields["Email"].typeText("testmail@gmail.com\n")
        
        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText("qqqqqq")
        
        app.staticTexts["LOGIN"].tap()
        
        app.alerts["Oops!"].buttons["OK"].tap()
        
    }

    func testLoginToMain() {
        
        app.segmentedControls.buttons["Login"].tap()
        
        let textField = app.textFields["Email"]
        textField.tap()
        textField.typeText("testmail@gmail.com")
        textField.typeText("\n")
        XCUIApplication().textFields["Email"].tap()

        let passwordSecureTextField = app.secureTextFields["Password"]
        passwordSecureTextField.tap()
        passwordSecureTextField.typeText("123abc")
        
        app.staticTexts["LOGIN"].tap()
        
        let ActiveSFUlabel = app.staticTexts["ACTIVE SFU"]
        waitForElementToAppear(ActiveSFUlabel)
        XCTAssert(ActiveSFUlabel.exists)
        
        app.buttons["x icon"].tap()
    }

    func testSurveyWhenRegistered() {
        
        //app.buttons["x icon"].tap()
        
        app.textFields["Name"].tap()
        app.textFields["Name"].typeText("Geralt \n")
       
        app.textFields["Email"].tap()
        app.textFields["Email"].typeText("wowie123@wow.com\n")
        
        app.secureTextFields["Password"].tap()
        app.secureTextFields["Password"].typeText("qqqqqq")
        
        
        app.staticTexts["REGISTER"].tap()
        
        let surveyView = app.navigationBars["Question"]
        waitForElementToAppear(surveyView)
        XCTAssert(surveyView.exists)
    }
    
}
