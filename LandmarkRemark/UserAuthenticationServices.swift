//
//  UserAuthenticationServices.swift
//  LandmarkRemark
//
//  Created by Gagandeep Singh on 30/6/16.
//  Copyright © 2016 Gagandeep Singh. All rights reserved.
//

import Parse

class UserAuthenticationService {
    
    func logInUser(withUsername username: String, andPassword password: String, complettion: (user: PFUser?, error: NSError?) -> Void) {
        
        PFUser.logInWithUsername(inBackground: username, password: password, block: { (user, error) -> Void in
            
            complettion(user: user, error: error)
            
        })
        
    }
    
    
    
    
    //Method to check availablity in User class.
    //Common usage: Email & Username
    func checkAvailabilityInUserClass(inField field: String, forValue value: String, completion: (available: Bool) -> Void ) {
        let query = PFUser.query()!
        query.whereKey(field, equalTo: value)
        query.getFirstObjectInBackground { (object, error) in
            if let _ = object {
                completion(available: false)
                
            } else {
                completion(available: true)
            }
        }
    }
    
    //Add current user to Parse Installation on login and sign up.
    func updateParseInstallation() {
        let installaion = PFInstallation.current()
        installaion.setValue(CurrentUser!.parseUser, forKey: "user")
        installaion.saveInBackground()
    }

}
