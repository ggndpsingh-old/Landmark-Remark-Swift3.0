//
//  LandmarksService.swift
//  LandmarkRemark
//
//  Created by Gagandeep Singh on 30/6/16.
//  Copyright © 2016 Gagandeep Singh. All rights reserved.
//

import Foundation
import CoreLocation
import Parse
import MapKit

public class LandmarksService {
    
    func fetchNotes(nearLocation location: CLLocationCoordinate2D, withinRadius radius: CLLocationDistance, completion: (notes: [NoteObject]?, error: NSError?) -> Void) {
        
        //Create parse geopoiint for location at center of map
        let geoPoint = PFGeoPoint(latitude: location.latitude, longitude: location.longitude)
        
        
        //Query for notes in map region
        let query = PFQuery(className: "Note")
        
        //Search within the visible area only
        query.whereKey("location", nearGeoPoint: geoPoint, withinKilometers: radius)
        
        //Inlude note user detail
        query.includeKey("user")
        query.findObjectsInBackground { (objects, error) in
            
            //If notes found, convert to Note Object and pass completion block
            
            if let notes = objects {
                var array = [NoteObject]()
                for note in notes {
                    let noteObject = NoteObject(withParseObject: note)
                    array.append(noteObject)
                }
                completion(notes: array, error: error)
                
            } else {
                
                completion(notes: nil, error: error)
            }
        }
    }
    
    func annotationExists(atCoordinates coordinates: CLLocationCoordinate2D,  inMapView mapView: MKMapView) -> Bool {
        
        for annotation in mapView.annotations {
            if annotation is MKUserLocation {
                return false
            }
            
            if annotation.coordinate.latitude == coordinates.latitude && annotation.coordinate.longitude == coordinates.longitude {
                return true
            }
        }
        
        return false
    }
    
}
