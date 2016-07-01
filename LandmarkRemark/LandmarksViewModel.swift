//
//  LandmarksViewModel.swift
//  LandmarkRemark
//
//  Created by Gagandeep Singh on 30/6/16.
//  Copyright © 2016 Gagandeep Singh. All rights reserved.
//

import Foundation
import Parse


// The protocol for Landmarks View Model Delegate, implemented by the Landmarks View Controller
public protocol LandmarksViewModelDelegate: class {
    
    func showLoading()
    func hideLoading()
    
    func updateMapView(withAnnotations: [NoteAnnotation])
    func resetMapView(withAnnotations: [NoteAnnotation])
}


//The View Model for Landmarks View Controller
public class LandmarksViewModel {
    
    public var searching = false
    
    private var notesSeparatedByAddress: NSDictionary!
    
    // The delgate of the view-model to call back / pass back information to the view-controller
    public weak var delegate: LandmarksViewModelDelegate?
    
    // reference to the Authentication service
    private let landmarkService: LandmarksService!
    
    // initializer
    public init(delegate: LandmarksViewModelDelegate) {
        self.delegate = delegate
        landmarkService = LandmarksService()
    }
    
    
    
    func loadNotes(nearLocation location: CLLocationCoordinate2D, withinRadius radius: CLLocationDistance, forString searchString: String) {
        
        searching = searchString != ""
        
        delegate?.showLoading()
        
        landmarkService.fetchNotes(nearLocation: location, withinRadius: radius) { (notes, error) in
            if let notes = notes {
                
                var filteredNotes = notes
                let searchString = searchString.trim().condenseWhitespace().lowercased()
                
                if searchString != "" {
                    
                    filteredNotes = filteredNotes.filter({ (note) -> Bool in
                        
                        let stringToMatch = note.searchString.trim().condenseWhitespace().lowercased()
                        
                        if stringToMatch.contains(searchString) {
                            return true
                        }
                        return false
                    })
                }
                
                self.delegate?.hideLoading()
                self.createAnnotations(fromNotes: filteredNotes)
                self.separateNotesByAddress(notes: filteredNotes)
            }
        }
        
    }
    
    private func createAnnotations(fromNotes notes: [NoteObject]) {
        
        var annotations = [NoteAnnotation]()
        
        for note in notes {
            
            //Create new Note Annotation
            let annotation = NoteAnnotation()
            
            //Set annnotation properties
            annotation.coordinate   = note.location.coordinate
            annotation.title        = note.user.username
            annotation.subtitle     = note.locationString
            annotation.note         = note
            
            annotations.append(annotation)
        }
        
        let _ = searching ? delegate?.resetMapView(withAnnotations: annotations) : delegate?.updateMapView(withAnnotations: annotations)
    
    }
    
    private func separateNotesByAddress(notes: [NoteObject]) {
        
        //Create a new mutable dictionary
        let dict = NSMutableDictionary()
        
        //Start with a set of Strings
        var addresses = Set<String>()
        
        //Add all unique addresses to Set
        for note in notes {
            addresses.insert(note.locationString)
        }
        
        //Find notes that match each address and create an array
        for address in addresses {
            let notesAtAddress = notes.filter({ (note) -> Bool in
                
                if note.locationString == address {
                    return true
                }
                return false
                
            })
        
        
            //Once the array is created, add it to the notes at address dictionary
            dict.setObject(notesAtAddress, forKey: address)
        }
        self.notesSeparatedByAddress = dict
        
    }
    
    //Method to return notes at a given address
    public func fetchNotes(atAddress address: String) -> [NoteObject] {
        
        var array = [NoteObject]()
        if let notesAtAddress = self.notesSeparatedByAddress.value(forKey: address) {
            array = notesAtAddress as! [NoteObject]
        }
        
        return array
    }
    
}
