//
//  ImageCacheTests.swift
//  MomentsTests
//
//  Created by zhangchenglong01 on 2020/4/4.
//  Copyright © 2020 zhangchenglong01. All rights reserved.
//

import Foundation
import XCTest
@testable import Moments

class ImageCacheTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testSetImage() {
        let imageView = UIImageView()
        
        let url = URL(string: "https://thoughtworks-mobile-2018.herokuapp.com/images/tweets/001.jpeg")
        let expection = XCTestExpectation(description: "setimage")
        
        imageView.setImage(with: url!, placeholder: nil) { (result) in
            expection.fulfill()
        }
        
        self.wait(for: [expection], timeout: 60)
    }
}
