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
import MapKit


//Validate Email Address
func isValidEmail(candidate: String) -> Bool {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
    return Predicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: candidate)
}

func convertMetersToKilometers(distance: CLLocationDistance) -> CLLocationDistance {
    return distance / 1000
}


//Generate string for show all notes button
func generateString(forNotesCount count: Int) -> String {
    
    let prefix  = NSLocalizedString("SHOW_ALL", comment: "Show all")
    let notes   = NSLocalizedString("NOTES", comment: "Notes")
    let postfix = NSLocalizedString("AT_THIS_LOCATION", comment: "at this location")
    
    return "\(prefix) \(count) \(notes) \(postfix)"
    
}
