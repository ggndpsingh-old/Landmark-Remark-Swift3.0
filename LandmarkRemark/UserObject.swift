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

class UserObject : NSObject, NSCoding {
    
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
        
        self.objectId   = pfUser.valueForKey("objectId") as! String
        self.username   = pfUser.valueForKey("username") as! String
        self.email      = pfUser.valueForKey("email") as! String
        self.notesCount = pfUser.valueForKey("notesCount") as! Int
        
        self.createdAt = pfUser.valueForKey("createdAt") as! NSDate
        self.updatedAt = pfUser.valueForKey("updatedAt") as! NSDate
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
        parseUser.signUpInBackgroundWithBlock { (success, error) in
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
        self.objectId   = aDecoder.decodeObjectForKey("objectId") as! String
        self.username   = aDecoder.decodeObjectForKey("username") as! String
        self.email      = aDecoder.decodeObjectForKey("email") as! String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self.objectId,  forKey: "objectId")
        aCoder.encodeObject(self.username,  forKey: "username")
        aCoder.encodeObject(self.email,     forKey: "email")
    }
    
}