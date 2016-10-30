//
//  MealTableViewController.swift
//  FoodTracker
//
//  Created by jim on 10/11/16.
//  Copyright © 2016 James C Smith. All rights reserved.
//

import UIKit
import MapKit

class MealTableViewController: UITableViewController, CLLocationManagerDelegate {
    // MARK: Properties
    
    private var meals = [Meal]()
    // create var and init it to a sort method. var sortMethod = "distance"  //options; "distance", "date", "
    private var searchType = SearchType.Nearest   // typical search time, nearest to where I am
    private var myLocation: CLLocation? {
        didSet {
            if searchType == .Nearest {
                sortMeals()    // sort the meals if location changes and searchType is by .Nearest
                tableView.reloadData()
            }
        }
    }
    private var locationManager = CLLocationManager()
    
    enum SearchType {
        case Ascending
        case Descending
        case Nearest
        case Time
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem
        
        if let savedMeals = loadMeals() {
            meals += savedMeals
        }else {
            // Load the sample data
            loadSampleMeals()
        }
        sortMeals()  //sort them according to global variable searchType, probably need to sort after return from seque
        // set up location
        self.locationManager.requestWhenInUseAuthorization()
        if (CLLocationManager.locationServicesEnabled()){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            print("location services enabled in MealTable")
        }
    }
    
    func loadSampleMeals() {
        //let urbanPlatesLoc = CLLocation().coordinate(l1)
        let urbanPlatesLoc = CLLocation(latitude: 32.951252, longitude: -117.232769)
        let photo1 = UIImage(named: "meal1")!
        let meal1 = Meal(name: "Caprese Salad", photo: photo1, rating: 4, restaurant: "Urban Plates", comments: "great salad", location: urbanPlatesLoc, when: nil)!
        let sbiccaLoc = CLLocation(latitude: 32.951262, longitude: -117.232769)
        let photo2 = UIImage(named: "meal2")!
        let meal2 = Meal(name: "Chicken and Potatoes", photo: photo2, rating: 5, restaurant: "Sbicca", comments: "sucks", location: sbiccaLoc, when: nil)!
        
        let pontLoc = CLLocation(latitude: 32.951272, longitude: -117.232769)
        let photo3 = UIImage(named: "meal3")!
        let meal3 = Meal(name: "Pasta with Meatballs", photo: photo3, rating: 3, restaurant: "Trattoria Ponte Vecchio", comments: "excellent pasta", location: pontLoc, when: nil)!
        
        meals += [meal1, meal2, meal3]
    }
    
    func sortMeals() {
        switch searchType {
        case .Ascending:
            meals.sort {$0.restaurant.lowercased() < $1.restaurant.lowercased()}
        case .Descending:
            meals.sort {$0.restaurant.lowercased() > $1.restaurant.lowercased()}
        case .Nearest:
            if myLocation != nil {
                meals.sort {$0.location!.distance(from: myLocation!) < ($1.location!.distance(from: myLocation!))}
            }
            
        case .Time:
            meals.sort {$0.when.compare($1.when as Date) == ComparisonResult.orderedDescending}
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1   // simple table just has one section
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals.count   // just the number of meals
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "MealTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! MealTableViewCell
        
        let meal = meals[indexPath.row]
        
        cell.nameLabel.text = meal.name
        cell.photoImageView.image = meal.photo
        cell.ratingControl.rating = meal.rating

        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            meals.remove(at: indexPath.row)
            saveMeals()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ShowDetail" {
            let mealDetailViewController = segue.destination as! MealViewController
            if let selectedMealCell = sender as? MealTableViewCell {
                let indexPath = tableView.indexPath(for: selectedMealCell)!
                let selectedMeal = meals[indexPath.row]
                mealDetailViewController.meal = selectedMeal
            }
        }
        else if segue.identifier == "AddItem" {
            print("Adding new meal.")
            
        }
        locationManager.startUpdatingLocation()  // updating location before adding or editing meal
        //print("location services enabled in MealTable2")
    }
 
    @IBAction func unwindToMealList(_ sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? MealViewController, let meal = sourceViewController.meal{
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // update an existing meal.
                meals[selectedIndexPath.row] = meal
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                // Add a new meal.
                //let newIndexPath = NSIndexPath(row: meals.count, section: 0)
                meals.append(meal)
                sortMeals()
                tableView.reloadData()  //maybe a more graceful way to add to top
                //tableView.insertRows(at: [newIndexPath as IndexPath], with: .top)
            }
            saveMeals()
        }
    }
    // MARK: NSCoding
    func saveMeals() {
        print(Meal.ArchiveURL.path)
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(meals, toFile: Meal.ArchiveURL.path)
        if !isSuccessfulSave {
            print("Failed to save meals...")
        }
    }
    func loadMeals() -> [Meal]? {
        //return nil // take this out when saveMeals() works
        return NSKeyedUnarchiver.unarchiveObject(withFile: Meal.ArchiveURL.path) as? [Meal]
    }
    // MARK: Delegate for location manager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations[0] != self.myLocation {
            //self.myLocation = locations[0]
            self.myLocation = CLLocation(latitude: 32.951252, longitude: -117.232769)   // near Urban Plates Del Mar Heighlands
            print("location updated, MealTable")
            self.locationManager.stopUpdatingLocation()
        }
    }
}
