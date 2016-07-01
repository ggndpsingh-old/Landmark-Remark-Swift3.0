//
//  UserObject.swift
//  LandmarkRemark
//
//  Created by Gagandeep Singh on 21/6/16.
//  Copyright © 2016 Gagandeep Singh. All rights reserved.
//

import Foundation
import UIKit
import Parse

class UserObject : NSObject {
    
    //Set user properties
    
    var parseUser   : PFUser!
    var objectId    : String!
    var username    : String!
    var email       : String!
    var notesCount  : Int!
    
    var createdAt   : NSDate!
    var updatedAt   : NSDate!

    var password    : String?
    
    
    //Empty Iint
    override init() {
        
    }
    
    
    //Initialize from Parse User
    init(withParseUser pfUser: PFUser) {
        
        //Set user values
        self.parseUser  = pfUser
        
        self.objectId   = pfUser.value(forKey:"objectId") as! String
        self.username   = pfUser.value(forKey:"username") as! String
        self.email      = pfUser.value(forKey:"email") as! String
        self.notesCount = pfUser.value(forKey:"notesCount") as! Int
        
        self.createdAt = pfUser.value(forKey:"createdAt") as! NSDate
        self.updatedAt = pfUser.value(forKey:"updatedAt") as! NSDate
    }
    
    
    //Sign Up new user
    func signUpAsNewUser(completion: ((success: Bool) -> Void)? ) {
        
        //Create new Parse user
        parseUser = PFUser()
        
        //Sset user properties
        parseUser.setValue(self.username, forKey: "username")
        parseUser.setValue(self.email, forKey: "email")
        parseUser.setValue(self.password!, forKey: "password")
        parseUser.setValue(0, forKey: "notesCount")
        
        //Sign Up User
        parseUser.signUpInBackground { (success, error) in
            if success {
                completion!(success: true)
                self.objectId = self.parseUser.objectId!
                
            } else {
                completion!(success: false)
            }
        }
        
    }
    
    
    //Update varialbe properties
    func updateParseUser() {
        parseUser.setValue(self.notesCount, forKey: "notesCount")
        parseUser.saveInBackground()
    }
    
    
    
    
    //Required NSObject initializers
    
    //Endcoding & Decoding to save User Object locally
    required init(coder aDecoder: NSCoder) {
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
    }
    
}
