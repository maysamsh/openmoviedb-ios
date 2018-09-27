//
//  OpenMovieTests.swift
//  OpenMovieTests
//
//  Created by Maysam Shahsavari on 9/17/18.
//  Copyright © 2018 Maysam Shahsavari. All rights reserved.
//

import XCTest
@testable import OpenMovie

class OpenMovieTests: XCTestCase {
    
    private let networkService = NetworkService.shared()
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSearch() {
        let promise = expectation(description: "Search for batman movies")
        networkService.search(for: "batman", page: 1) { (searchObject, error) in
            XCTAssertNil(error)
            XCTAssertTrue(searchObject?.response == "True")
            promise.fulfill()
        }
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testSearchByIMDBID() {
        let promise = expectation(description: "Search for Batman: Dark Night Returns")
        networkService.getMovie(with: "tt2313197") { (movieObject, error) in
            XCTAssertNil(error)
            XCTAssertTrue(movieObject?.imdbID == "tt2313197")
            promise.fulfill()
        }
     
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
