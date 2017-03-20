//
//  UITestCase.swift
//  ACTIVESFU
//
//  Created by CoolMac on 2017-03-19.
//  Copyright © 2017 CMPT276 Group 10. All rights reserved.
//

import XCTest

class UITestCase: XCTestCase {
    
    let app = XCUIApplication()
    override func setUp() {
        super.setUp()
        super.setUp()
        continueAfterFailure = false
        app.launch()
    }
    
    override func tearDown() {
        super.tearDown()
        app.terminate()
    }

    func waitForElementToAppear(_ element: XCUIElement, file: String = #file, line: UInt = #line) {
        let existsPredicate = NSPredicate(format: "exists == true")
        expectation(for: existsPredicate, evaluatedWith: element, handler: nil)
        
        waitForExpectations(timeout: 5) { (error) -> Void in
            if (error != nil) {
                let message = "Failed to find \(element) after 5 seconds."
                self.recordFailure(withDescription: message, inFile: file, atLine: line, expected: true)
            }
        }
    }
    
}
