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
    
    func createSearchString() -> String {
        return "\(user.username) - \(locationString) - \(note)".lowercaseString
    }
    
    override init() {
        
    }
    
    init(withParseObject pfObject: PFObject) {
        self.parseObject = pfObject
        self.objectId = pfObject.objectId!
        
        self.note           = pfObject.valueForKey("note") as! String
        self.locationString = pfObject.valueForKey("locationString") as! String
        self.searchString   = pfObject.valueForKey("searchString") as! String
        
        self.createdAt      = pfObject.valueForKey("createdAt") as! NSDate
        self.updatedAt      = pfObject.valueForKey("updatedAt") as! NSDate
        
        let user = pfObject.valueForKey("user") as! PFUser
        self.user = UserObject(withParseUser: user)
        
        let geopoint = pfObject.valueForKey("location") as! PFGeoPoint
        self.location = CLLocation(latitude: geopoint.latitude, longitude: geopoint.longitude)
        
        self.detailsString = "\(locationString) - \(createdAt.longFormat())"
    }
    
    
    func saveAsNewNote(completion: (success: Bool) -> Void) {
        
        parseObject = PFObject(className: "Note")
        
        parseObject.setValue(self.note,                 forKey: "note")
        parseObject.setValue(self.locationString,       forKey: "locationString")
        parseObject.setValue(self.createSearchString(), forKey: "searchString")
        parseObject.setValue(CurrentUser!.parseUser,    forKey: "user")
        
        let geoPoint = PFGeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        parseObject.setValue(geoPoint, forKey: "location")
        
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
    
    func updateParseObject() {
        let searchString = createSearchString()
        parseObject.setValue(note, forKey: "note")
        parseObject.setValue(searchString, forKey: "searchString")
    }
    
    
    
    required init(coder aDecoder: NSCoder) {
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
    }
    
}