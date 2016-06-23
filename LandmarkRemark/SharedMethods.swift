//
//  SharedMethods.swift
//  LandmarkRemark
//
//  Created by Gagandeep Singh on 21/6/16.
//  Copyright © 2016 Gagandeep Singh. All rights reserved.
//

import UIKit
import Parse
import CoreLocation

//Method to check availablity in User class.
//Common usage: Email & Username
func checkAvailabilityInUserClass(inField field: String, forValue value: String, completion: (available: Bool) -> Void ) {
    let query = PFUser.query()!
    query.whereKey(field, equalTo: value)
    query.getFirstObjectInBackgroundWithBlock { (object, error) in
        if let _ = object {
            completion(available: false)
        
        } else {
            completion(available: true)
        }
    }
}

//Add current user to Parse Installation on login and sign up.
func updateParseInstallation() {
    let installaion = PFInstallation.currentInstallation()
    installaion.setValue(CurrentUser!.parseUser, forKey: "user")
    installaion.saveInBackground()
}


//Validate Email Address
func isValidEmail(candidate: String) -> Bool {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
    return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluateWithObject(candidate)
}

func convertMetersToKilometers(distance: CLLocationDistance) -> CLLocationDistance {
    return distance / 1000
}