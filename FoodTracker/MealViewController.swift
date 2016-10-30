//
//  MealViewController.swift
//  FoodTracker
//
//  Created by jim on 9/26/16.
//  Copyright © 2016 James C Smith. All rights reserved.
//

import UIKit
import MapKit

class MealViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate,
                            UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate{ //
    // MARK: Properties
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var restaurantTextBox: UITextField!
    @IBOutlet weak var dropDown: UIPickerView!
    @IBOutlet weak var commentsTextView: UITextView!
    
    private let minMealNameLength = 3
    /*
     This value is either passed by 'MealTableViewController' in 'prepareForSeque(_:sender:)'
     or constructed as part of adding a new meal.
     */
    var meal: Meal?
    //private var restaurantList = ["Urban Plates", "Casa Sol y Mar", "Taverna Blu", "Carnitas Snack Shack", "Sammy's Woodfired Pizza"]
    private var restaurantList = [String]()   //empty string array
    private var myLocation: CLLocation?
    private var locationManager = CLLocationManager()
    //private var mapView: MKMapView!
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.nameTextField {
            // Disable the Save button while editing.
            checkValidMealName()
        }
        if textField == self.restaurantTextBox {
            self.dropDown.isHidden = false
            //if you don't want the users to see the keyboard type:
            
            //textField.endEditing(true)  // commented this out because I want to change the restaurant
        }
    }
    func checkValidMealName() {
        // Disable the Save button if the text field is ..
        let text = nameTextField.text ?? ""
        if text.characters.count < minMealNameLength {
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.nameTextField {
            //mealNameLabel.text = textField.text
            checkValidMealName()
            navigationItem.title = textField.text
        }
    }
    
    // MARK: UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // The info dictionary contains multiple representations of the image, and this uses the original.
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        // Set photoImageView to display the selected image.
        photoImageView.image = selectedImage
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    // MARK: Navigation
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        if isPresentingInAddMealMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController!.popViewController(animated: true)
        }
    }
    
    
    // This method lets you configure a view controller before it's presented.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let mySender = sender as? UIBarButtonItem
        if saveButton === mySender {
            let name = nameTextField.text ?? ""
            let photo = photoImageView.image
            let rating = ratingControl.rating
            let restaurant = self.restaurantTextBox.text ?? ""
            let comments = self.commentsTextView.text
            // the location should only be updated the first time
            var location = (meal?.location)
            if location == nil {
                location = self.myLocation
            }
            let when = (meal?.when)  // when is assigned a date when the meal is first created
            // Set the meal to be passed to MealTableViewController after the unwind segue.
            meal = Meal(name: name, photo: photo, rating: rating, restaurant: restaurant, comments: comments, location: location, when: when)
        }
    }
    // MARK: Actions

    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        // Hide keyboard
        nameTextField.resignFirstResponder()
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        // Only allow photos to be picked, not taken
        imagePickerController.sourceType = .photoLibrary
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle the text field’s user input through delegate callbacks.
        nameTextField.delegate = self
        // Set up views if editing an existing Meal.
        if let meal = meal {
            navigationItem.title = meal.name
            nameTextField.text = meal.name
            photoImageView.image = meal.photo
            ratingControl.rating = meal.rating
            restaurantTextBox.text = meal.restaurant
            commentsTextView.text = meal.comments
        }
        // set up location
        self.locationManager.requestWhenInUseAuthorization()
        //print("did load ")
        if (CLLocationManager.locationServicesEnabled()){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            print("location services enabled")
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        // Enable the Save button only if the text field has a valid Meal name.
        checkValidMealName()
    }
    // MARK: ui picker delegate methods, https://makeapppie.com/tag/uipickerview-in-swift/
    // MARK: Data Sources
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return restaurantList.count
    }
    // MARK: UIPicker Delegates
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        self.view.endEditing(true)
        return restaurantList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.restaurantTextBox.text = self.restaurantList[row]
        self.dropDown.isHidden = true
    }
 
    // MARK: Delegate for location manager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations[0] != self.myLocation {
            self.myLocation = locations[0]
            let location = locations[0]  // temp variable
            //let location = CLLocation(latitude: 32.951252, longitude: -117.232769)   // near Urban Plates Del Mar Heighlands
            print("location updated")
            // perform local search ,    http://stackoverflow.com/questions/30992213/swift-mapkit-automatic-business-search
            let request = MKLocalSearchRequest()
            let span = MKCoordinateSpan(latitudeDelta: 0.0001, longitudeDelta: 0.0001)  // 0.1 is degrees, too big? too small? .01 seems to be a couple of blocks
            request.region = MKCoordinateRegion(center: location.coordinate, span: span)
            request.naturalLanguageQuery = "Restaurants"
            let search = MKLocalSearch(request: request)
            
            search.start(completionHandler : { (response:MKLocalSearchResponse?, error:Error?) in
                if error == nil {
                    for item in (response?.mapItems)! {
                        //print(item.name!)
                        self.restaurantList += [item.name!]
                    }
                    self.dropDown.reloadAllComponents()
                    self.locationManager.stopUpdatingLocation()   // a user will have to close the add meal screen to get another set of restaurants
                }
            })
        }
    }
}

