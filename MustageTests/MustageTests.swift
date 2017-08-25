//
//  MustageTests.swift
//  MustageTests
//
//  Created by Oleg Baidalka on 20/03/2017.
//  Copyright © 2017 Bossly. All rights reserved.
//

import XCTest

import Firebase
@testable import Mustage

class MustageTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testModelLoad() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertFalse(User("key here").isDataLoaded, "User, intialized shoudn't load data in contructor.")
        XCTAssertFalse(Story("key here").isDataLoaded, "Story, intialized shoudn't load data in contructor.")
        XCTAssertFalse(Comment("key here").isDataLoaded, "Comment, intialized shoudn't load data in contructor.")
        XCTAssertFalse(Like("key here").isDataLoaded, "Like, intialized shoudn't load data in contructor.")
        XCTAssertFalse(Favorite("key here").isDataLoaded, "Favorite, intialized shoudn't load data in contructor.")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
