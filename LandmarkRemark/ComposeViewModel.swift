//
//  ComposeViewModel.swift
//  LandmarkRemark
//
//  Created by Gagandeep Singh on 30/6/16.
//  Copyright © 2016 Gagandeep Singh. All rights reserved.
//

import Foundation
import CoreLocation


// The protocol for Compose View Model delegate, implemented by the Compose View Controller
public protocol ComposeViewModelDelegate: class {
    
    func noteSavedSuccessfully(note: NoteObject)
    func noteNotSaved()
    
    func noteEditedSuccessfully(note: NoteObject)
    
    func showProcessing()
    func hideProcessing()
    
}


// The View Model for Compose View Controller
public class ComposeViewModel {
    
    // The delgate of the view-model to call back / pass back information to the view-controller
    public weak var delegate: ComposeViewModelDelegate?
    
    // reference to the Authentication service
    private let landmarkService: LandmarksService!
    
    // initializer
    public init(delegate: ComposeViewModelDelegate) {
        self.delegate = delegate
        landmarkService = LandmarksService()
    }
    
    func createNewNote(withBody body: String, forUser user: UserObject, atLocation location: CLLocation, withAddress address: String) {
        
        delegate?.showProcessing()
        
        let note = NoteObject()
        
        //Add note values
        note.note = body
        note.user = user
        note.location = location
        note.locationString = address
        
        note.saveAsNewNote { (success, error) in
            
            if success {
                //Update user notes count
                CurrentUser!.notesCount = CurrentUser!.notesCount + 1
                CurrentUser!.updateParseUser()
                
                self.delegate?.noteSavedSuccessfully(note: note)
            } else {
                
                self.delegate?.noteNotSaved()
            }
            
            self.delegate?.hideProcessing()
            
        }
    }
    
    func updateNote(note: NoteObject, withBody body: String) {
        
        delegate?.showProcessing()
        
        note.note = body
        note.updateParseObject()
        
        note.parseObject.saveInBackground({ (success, error) in
            
            if success {
                self.delegate?.noteEditedSuccessfully(note: note)
                
            } else {
                
                self.delegate?.noteNotSaved()
            }
            
            self.delegate?.hideProcessing()
        })
    }
    
}
