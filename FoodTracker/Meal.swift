//
//  Meal.swift
//  FoodTracker
//
//  Created by jim on 10/1/16.
//  Copyright © 2016 James C Smith. All rights reserved.
//

import UIKit
import MapKit

class Meal: NSObject, NSCoding{  //, MKMapViewDelegate ( I added this, don't know why, then removed it
    // MARK: Properties
    
    var name: String
    var photo: UIImage?
    var rating: Int
    var restaurant: String
    var comments: String?
    var location: CLLocation?
    var when: NSDate
    
    //private var locationManager = CLLocationManager()
    
    // MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("meals")
    
    // MARK: Types
    struct PropertyKey {
        static let nameKey = "name"
        static let photoKey = "photo"
        static let ratingKey = "rating"
        static let commentKey = "comments"
        static let restaurantKey = "restaurant"
        static let locationKey = "location"
        static let dateKey = "date"
    }
    
    // MARK: Initialization
    
    init?(name: String, photo: UIImage?, rating: Int, restaurant: String, comments: String?, location: CLLocation?, when: NSDate?) {
        // Initialize stored properties.
        self.name = name
        self.photo = photo
        self.rating = rating
        self.restaurant = restaurant
        self.comments = comments
        self.location = location
        if (when == nil){
            self.when = NSDate()
        }else {
            self.when = when!
        }
        
        
        // Initialization should fail if there is no name or if the rating is negative.
        if name.isEmpty || rating < 0 || restaurant.isEmpty {
            return nil
        }
    }
    // MARK: NSCoding   
    // to persist the meals. These two functions are requred for the NSCoding delegate
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.nameKey)
        aCoder.encode(photo, forKey: PropertyKey.photoKey)
        aCoder.encode(rating, forKey: PropertyKey.ratingKey)
        aCoder.encode(restaurant, forKey: PropertyKey.restaurantKey)
        aCoder.encode(comments, forKey: PropertyKey.commentKey)
        aCoder.encode(location, forKey: PropertyKey.locationKey)
        aCoder.encode(when, forKey: PropertyKey.dateKey)
    }
    required convenience init?(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: PropertyKey.nameKey) as! String
        // Because photo is an optional property of Meal, use conditional cast.
        let photo = aDecoder.decodeObject(forKey: PropertyKey.photoKey) as? UIImage
        let rating = aDecoder.decodeInteger(forKey: PropertyKey.ratingKey)
        //let rating = aDecoder.decodeObject(forKey: PropertyKey.ratingKey) as! Int
        let restaurant = aDecoder.decodeObject(forKey: PropertyKey.restaurantKey) as! String
        let comments = aDecoder.decodeObject(forKey: PropertyKey.commentKey) as? String
        let location = aDecoder.decodeObject(forKey: PropertyKey.locationKey) as? CLLocation
        let when = aDecoder.decodeObject(forKey: PropertyKey.dateKey) as? NSDate
        // Must call designated initializer
        self.init(name: name, photo: photo, rating: rating, restaurant: restaurant, comments: comments, location: location, when: when)
    }
}
