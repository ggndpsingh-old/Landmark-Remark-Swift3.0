//
//  NoteObject.swift
//  LandmarkRemark
//
//  Created by Gagandeep Singh on 22/6/16.
//  Copyright © 2016 Gagandeep Singh. All rights reserved.
//

import Foundation
import Parse
import CoreLocation

class NoteObject: NSObject, NSCoding {
    
    //Set note variables
    
    var parseObject     : PFObject!
    var objectId        : String!
    var note            : String!
    var user            : UserObject!
    var location        : CLLocation!
    var locationString  : String!
    var searchString    : String!
    var detailsString   : String!
    
    var createdAt   : NSDate!
    var updatedAt   : NSDate!
    
    
    //Create note search string
    func createSearchString() -> String {
        return "\(user.username) - \(locationString) - \(note)".lowercaseString
    }
    
    
    //Empty Initializer
    override init() {
        
    }
    
    
    //Initialize Note from a Parse Object
    init(withParseObject pfObject: PFObject) {
        
        //populise properties
        self.parseObject = pfObject
        self.objectId = pfObject.objectId!
        
        //Get valus for Parse Object
        self.note           = pfObject.valueForKey("note") as! String
        self.locationString = pfObject.valueForKey("locationString") as! String
        self.searchString   = pfObject.valueForKey("searchString") as! String
        
        self.createdAt      = pfObject.valueForKey("createdAt") as! NSDate
        self.updatedAt      = pfObject.valueForKey("updatedAt") as! NSDate
        
        //Conver Parse User to User Object
        let user = pfObject.valueForKey("user") as! PFUser
        self.user = UserObject(withParseUser: user)
        
        //Conver Parse GeoPoint to CLLocation
        let geopoint = pfObject.valueForKey("location") as! PFGeoPoint
        self.location = CLLocation(latitude: geopoint.latitude, longitude: geopoint.longitude)
        
        //Create details string
        self.detailsString = "\(locationString) - \(createdAt.longFormat())"
    }
    
    
    //Save a new not to Parse with completion block
    func saveAsNewNote(completion: (success: Bool) -> Void) {
        
        //Set parseObject as a new Parse Object of Note class
        parseObject = PFObject(className: "Note")
        
        //Set note valuds
        parseObject.setValue(self.note,                 forKey: "note")
        parseObject.setValue(self.locationString,       forKey: "locationString")
        parseObject.setValue(self.createSearchString(), forKey: "searchString")
        parseObject.setValue(CurrentUser!.parseUser,    forKey: "user")
        
        //Convert note loation to Parse GeoPoint
        let geoPoint = PFGeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        parseObject.setValue(geoPoint, forKey: "location")
        
        //Save parse object
        parseObject.saveInBackgroundWithBlock { (success, error) in
            if success {
                self.objectId = self.parseObject.objectId!
                completion(success: true)
            
            } else {
                print(error?.description)
                completion(success: false)
            }
        }
    }
    
    //Update varialbe properties on Note Object
    func updateParseObject() {
        let searchString = createSearchString()
        parseObject.setValue(note, forKey: "note")
        parseObject.setValue(searchString, forKey: "searchString")
    }
    
    
    //Required NSOBject initializers
    required init(coder aDecoder: NSCoder) {
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
    }
    
}