//
//  MGVolumeButtonsTests.swift
//  MGVolumeButtonsTests
//
//  Created by Ann Greenwald on 2/27/16.
//  Copyright © 2016 Max Greenwald. All rights reserved.
//

import XCTest
@testable import MGVolumeButtons

class MGVolumeButtonsTests: XCTestCase {
    
    var stealer: MGVolumeButtons!
    
    override func setUp() {
        super.setUp()
        stealer = MGVolumeButtons()
        stealer.startStealing()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
