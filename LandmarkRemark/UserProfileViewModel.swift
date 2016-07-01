//
//  UserProfileViewModel.swift
//  LandmarkRemark
//
//  Created by Gagandeep Singh on 30/6/16.
//  Copyright © 2016 Gagandeep Singh. All rights reserved.
//

import Foundation
import Parse

// The protocol for User Profile View delegate, implemented by the User Profile View Controller
public protocol UserProfileViewModelDelegate: class {
    
}

//The View Model for User Profile View Controller
public class UserProfileVewModel {
    
    // The delgate of the view-model to call back / pass back information to the view-controller
    public weak var delegate: UserProfileViewModelDelegate?
    
    // reference to the Authentication service
    private let authenticationService: UserAuthenticationService
    
    // initializer
    public init(delegate: UserProfileViewModelDelegate) {
        self.delegate = delegate
        authenticationService = UserAuthenticationService()
    }
    
    
    func fetchNotes(forUser user: UserObject, completion: (notes: [NoteObject]?, error: NSError?) -> Void) {
        
        var notes = [NoteObject]()
        
        //Fetch user notes
        let query = PFQuery(className: "Note")
        query.whereKey("user", equalTo: user.parseUser)
        query.includeKey("user")
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground { (objects, error) in
            
            if let objects = objects {
            
                for note in objects {
                    notes.append(NoteObject(withParseObject: note))
                }
                completion(notes: notes, error: error)
                
            } else {
                completion(notes: nil, error: error)
            }
        }
    }
    
    
    func logOut(completion: (error: NSError?) -> Void) {
        
        PFUser.logOutInBackground { (error) in
            completion(error: error)
        }
        
    }
    
    
    
}
