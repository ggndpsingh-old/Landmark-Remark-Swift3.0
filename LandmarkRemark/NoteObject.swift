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

public class NoteObject: NSObject {
    
    //Set note variables
    
    var parseObject     : PFObject!
    var objectId        : String!
    var note            : String!
    var user            : UserObject!
    var location        : CLLocation!
    var locationString  : String!
    var searchString    : String!
    var detailsString   : String!
    
    var likes           : Int!
    var likedBy         : [String]!
    
    var createdAt   : NSDate!
    var updatedAt   : NSDate!
    
    
    //Create note search string
    func createSearchString() -> String {
        return "\(user.username!) - \(locationString!) - \(note!)".lowercased()
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
        self.note           = pfObject.value(forKey: "note") as! String
        self.locationString = pfObject.value(forKey:"locationString") as! String
        self.searchString   = pfObject.value(forKey:"searchString") as! String
        
        self.createdAt      = pfObject.value(forKey:"createdAt") as! NSDate
        self.updatedAt      = pfObject.value(forKey:"updatedAt") as! NSDate
        
        self.likes          = pfObject.value(forKey: "likes") as! Int
        self.likedBy        = pfObject.value(forKey: "likedBy") as! [String]
        
        //Conver Parse User to User Object
        let user = pfObject.value(forKey:"user") as! PFUser
        self.user = UserObject(withParseUser: user)
        
        //Conver Parse GeoPoint to CLLocation
        let geopoint = pfObject.value(forKey:"location") as! PFGeoPoint
        self.location = CLLocation(latitude: geopoint.latitude, longitude: geopoint.longitude)
        
        //Create details string
        self.detailsString = "\(locationString) - \(createdAt.longFormat())"
    }
    
    
    //Save a new note to Parse with completion block
    func saveAsNewNote(completion: (success: Bool, error: NSError?) -> Void) {
        
        //Set parseObject as a new Parse Object of Note class
        parseObject = PFObject(className: "Note")
        
        //Set note valuds
        parseObject.setValue(self.note,                 forKey: "note")
        parseObject.setValue(self.locationString,       forKey: "locationString")
        parseObject.setValue(self.createSearchString(), forKey: "searchString")
        parseObject.setValue(CurrentUser!.parseUser,    forKey: "user")
        
        parseObject.setValue(0,                         forKey: "likes")
        parseObject.setValue([],                        forKey: "likedBy")
        
        //Convert note loation to Parse GeoPoint
        let geoPoint = PFGeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        parseObject.setValue(geoPoint, forKey: "location")
        
        //Save parse object
        parseObject.saveInBackground { (success, error) in
            if success {
                self.objectId = self.parseObject.objectId!
                completion(success: true, error: error)
            
            } else {
                print(error?.description)
                completion(success: false, error: error)
            }
        }
    }
    
    //Update varialbe properties on Note Object
    func updateParseObject() {
        
        parseObject.setValue(note, forKey: "note")
        parseObject.setValue(createSearchString(), forKey: "searchString")
        
        parseObject.setValue(likes, forKey: "likes")
        parseObject.setValue(likedBy, forKey: "likedBy")
    }
    
    
    func deleteNote(completion: (success: Bool, error: NSError?) -> Void) {
        
        parseObject.deleteInBackground { (success, error) in
            completion(success: success, error: error)
        }
        
    }
    
    
    //Required NSOBject initializers
    required public init(coder aDecoder: NSCoder) {
        
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
    }
    
}
