//
//  FoodTrackerTests.swift
//  FoodTrackerTests
//
//  Created by jim on 9/26/16.
//  Copyright © 2016 James C Smith. All rights reserved.
//
import UIKit
import XCTest
//@testable import FoodTracker

class FoodTrackerTests: XCTestCase {
    
    // MARK: FoodTracker Tests
    
    // Tests to confirm that the Meal initializer returns when no name or a negative rating is provided.
    func testMealInitialization() {
        let potentialItem = Meal(name: "newest meal", photo: nil, rating: 5, restaurant: nil, comments: nil, location: nil)
        XCTAssertNotNil(potentialItem)
        // Failure cases.
        let noName = Meal(name: "", photo: nil, rating: 0, restaurant: nil, comments: nil, location: nil)
        XCTAssertNil(noName, "Empty name is invalid")
        
        let badRating = Meal(name: "Really bad rating", photo: nil, rating: -1, restaurant: nil, comments: nil, location: nil)
        XCTAssertNil(badRating, "Negative ratings are invalid, be positive")
    }
    
}
