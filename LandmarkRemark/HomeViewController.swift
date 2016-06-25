//
//  HomeViewController.swift
//  LandmarkRemark
//
//  Created by Gagandeep Singh on 22/6/16.
//  Copyright © 2016 Gagandeep Singh. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit
import Parse
import AddressBookUI

class HomeViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITextFieldDelegate {
    
    //MARK:- OUTLETS
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var noteView: UIView!
    @IBOutlet weak var noteViewBottomLayout: NSLayoutConstraint!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var searchInput: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var currentLocationButton: UIButton!
    
    //MARK:- VARIABLES
    
    //init location manager
    var locationManager: CLLocationManager!
    
    //user current locations
    var currentLocation : CLLocation!
    
    //save last location whenever map region changes
    var lastLocation: CLLocation!
    
    //Location String
    var locationString: String!
    
    //Array for notes
    var parseNotes: [PFObject]!
    
    //Note Objects
    var noteObjects: [NoteObject]!
    
    //Selected Note
    var selectedNote: NoteObject?
    
    //tap to dismiss keyboard
    var tap: UITapGestureRecognizer!

    
    
    //MARK:- METHODS
    //MARK:- METHODS
    func getLocationAuthorization() {
        let status: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        
        switch status {
        case .NotDetermined:
            locationManager.requestWhenInUseAuthorization()
            
        case .Restricted:
            showRestrictedAuthorizationAlert()
            
        case .Denied:
            showDeniedAuthorizationAlert()
            
        default:
            break;
        }
        
    }
    
    //Show alert if user has denied Location Access
    func showDeniedAuthorizationAlert() {
        let title = NSLocalizedString("LOCATION_ACCESS_TITLE", comment: "Location access title")
        let message = NSLocalizedString("LOCATION_ACCESS_MESSAGE", comment: "Location access message")
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"), style: .Cancel, handler: nil)
        let settingsAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("SETTINGS", comment: "Settings"), style: .Default) { (action) in
            
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(settingsAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //Show alert if user lcoation is restricted on device
    func showRestrictedAuthorizationAlert() {
        let title = NSLocalizedString("LOCATION_RESTRICTED_TITLE", comment: "Location restricted title")
        let message = NSLocalizedString("LOCATION_RESTRICTED_MESSAGE", comment: "Location restricted message")
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        self.noteViewBottomLayout.constant = 0 - self.noteView.frame.height
        
        //Setup Location Manager
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        
        //Setup Map View
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = MKUserTrackingMode.Follow
        
        //Setup Search Input
        searchInput.delegate = self
        searchInput.addTarget(self, action: #selector(textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        searchInput.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.02)
        
        //Setup Tap
        tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadNotes), name: "newNoteSaved", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //Set Shadows
        currentLocationButton.layer.shadowColor = UIColor.blackColor().CGColor
        currentLocationButton.layer.shadowRadius = 2
        currentLocationButton.layer.shadowOffset = CGSizeMake(0, 0)
        currentLocationButton.layer.shadowOpacity = 0.2
        
        //Make sure Map View doesnt cover any other views
        view.sendSubviewToBack(mapView)
        
        //Populise Strings
        editButton.setTitle(NSLocalizedString("EDIT", comment: "Edit"), forState: .Normal)
    }
    
    
    //Reload notes if required
    func reloadNotes() {
        fetchNotesInCurrentArea()
        goToCurrentLocation()
    }
    
    
    
    //MARK:- LOCATION MANAGER DELEGATE
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        manager.startUpdatingLocation()
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //Set current Location and last Location on location change
        currentLocation = locations[0]
        lastLocation = locations[0]
        
        //get location information
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(manager.location!) { (placemarks, error) -> Void in
            
            if error == nil {
            
                if placemarks!.count > 0 {
                    
                    //Get address string for location
                    self.getLocationInfo(placemarks![0] as CLPlacemark)
                }
            
            } else {
                print(error)
            }
        }
    }
    
    
    func getLocationInfo(placemark : CLPlacemark) {
        
        //Create address string for location
        if let addressDictionary: NSDictionary = placemark.addressDictionary {
            let strings = addressDictionary["FormattedAddressLines"]
            locationString = strings!.componentsJoinedByString(" ")
            
        } else {
            
            let subLocality = placemark.subLocality == nil ? "" : placemark.subLocality!
            let locality    = placemark.locality    == nil ? "" : placemark.locality!
            let postcode    = placemark.postalCode  == nil ? "" : placemark.postalCode!
            let country     = placemark.country     == nil ? "" : placemark.country!
            
            let string = "\(subLocality) \(locality) \(postcode) \(country)"
            locationString = string
        }
        
    }
    
    
    
    
    
    
    //MARK:- MAP VIEW DELEGATE
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        //Update notes when region changes
        fetchNotesInCurrentArea()
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        
        //Show note details when a pin is selected
        if let annotation = view.annotation as? NoteAnnotation {
            selectedNote = annotation.note
            
            //Populize note details
            usernameLabel.text = selectedNote!.user.username
            locationLabel.text = selectedNote!.locationString
            dateLabel.text = selectedNote!.createdAt.longFormat()
            noteLabel.text = selectedNote!.note
            
            //If user owns note, show edit button
            editButton.hidden = CurrentUser!.username != selectedNote!.user.username
            
            //Present note details
            UIView.animateWithDuration(0.2) {
                self.noteViewBottomLayout.constant = 0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func mapView(mapView: MKMapView, didDeselectAnnotationView view: MKAnnotationView) {
        
        //Reset note details view
        self.usernameLabel.text = ""
        self.locationLabel.text = ""
        self.dateLabel.text = ""
        self.noteLabel.text = ""
        
        //Hide note details view
        UIView.animateWithDuration(0.2) {
            self.noteViewBottomLayout.constant = 0 - self.noteView.frame.height
            self.view.layoutIfNeeded()
        }
    }
    
    func getMapViewRadius() -> CLLocationDistance {
        
        //Calculate the area of map on screen
        
        //Get location at the center of the map
        let centerCoordinates = mapView.centerCoordinate
        let centerLocation = CLLocation(latitude: centerCoordinates.latitude, longitude: centerCoordinates.longitude)
        
        //Get location at the top of the map
        let topCenterCoordinates = mapView.convertPoint(CGPointMake(self.mapView.frame.size.height / 2, 0), toCoordinateFromView: mapView)
        let topCenterLocation = CLLocation(latitude: topCenterCoordinates.latitude, longitude: topCenterCoordinates.longitude)
        
        //Calculate distance from Center of map to Top of map
        let radius: CLLocationDistance = centerLocation.distanceFromLocation(topCenterLocation)
        let radiusInKilometers = convertMetersToKilometers(radius)
        
        //Return distance
        return radiusInKilometers
    }
    
    @IBAction func deselectAnnotationView() {
        mapView.deselectAnnotation(mapView.selectedAnnotations[0], animated: true)
    }
    
    @IBAction func goToCurrentLocation() {
        mapView.setCenterCoordinate(mapView.userLocation.coordinate, animated: true)
    }
    
    
    
    //MARK:- PREPARE FOR SEGUE
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        
        //Check Location Authorization and show alerts if Not Authorised
        getLocationAuthorization()
        
        //Perform segue only if Authorized
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            if sender as? UIButton == editButton {
                deselectAnnotationView()
            }
            return true
        }
        
        return false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        //Prepare for segue to Compose View
        let sender = sender as! UIButton
        let composeVc = segue.destinationViewController as! ComposeViewController
        
        switch sender {
        case editButton:
            //If editing a Note, set the complete note details
            composeVc.editingNote   = true
            composeVc.noteToEdit    = selectedNote
            composeVc.locality      = selectedNote!.locationString
            composeVc.location      = selectedNote!.location
            
        default:
            composeVc.locality      = self.locationString
            composeVc.location      = self.currentLocation
        }
    }
    
    
    
    
    
    //MARK:- TEXT FIELD DELEGATE
    func textFieldDidBeginEditing(textField: UITextField) {
        view.addGestureRecognizer(tap)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        view.removeGestureRecognizer(tap)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func textFieldDidChange(textField: UITextField) {
        //Perform search based on input
        self.fetchNotesInCurrentArea()
    }
    
    
    
    
    
    //MARK:- FETCHING NEW NOTES
    func fetchNotesInCurrentArea() {
        
        //Show loading indicator
        spinner.startAnimating()
        clearButton.hidden = true
        
        //Get search input
        let searchText = self.searchInput.text!
        
        //Create regex to match seatch input with Search String
        let regex : String = "(?i:\(searchText))"
        
        //Create parse geopoiint for location at center of map
        let geoPoint = PFGeoPoint(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        
        
        //Initialize Parse Notes Array
        parseNotes = [PFObject]()
        
        //Query for notes in map region
        let query = PFQuery(className: "Note")
        
        //If search input is empty, this statement will return all the results
        query.whereKey("searchString", matchesRegex: regex)
        
        //Search within the visible area only
        query.whereKey("location", nearGeoPoint: geoPoint, withinKilometers: getMapViewRadius())
        
        //Inlude note user detail
        query.includeKey("user")
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if let notes = objects {
                //If notes found, set Parse Notes array and add annotaions to the map
                self.parseNotes = notes
                self.addNoteAnnotations()
            }
            
            //Hide loading spinner
            self.spinner.stopAnimating()
            
            //If search input is not empty, show clear button
            if searchText != "" {
                //If searching, show clear button
                self.clearButton.hidden = false
            }
        }
    }
    
    
    
    
    
    //MARK:- ADD ANNOTATIONS
    func addNoteAnnotations() {
        
        //Initialize Note Objects array
        noteObjects = [NoteObject]()
        
        //Create an empty array to store found annotations
        var annotations = [NoteAnnotation]()
        
        //Go through each note
        for note in parseNotes {
            //Conver note to Note Object
            let noteObject = NoteObject(withParseObject: note)
            
            //Check if note already in the Note Objects array to avoild duplicates
            if noteObjects.indexOf({$0.objectId == noteObject.objectId}) == nil {
                
                //Add Note Object to array
                noteObjects.append(noteObject)
                
                //Check if an annotation already exsits at note location
                let noteCoordinates = noteObject.location.coordinate
                if !annotationExists(atCoordinates: noteCoordinates, inMapView: mapView) {
                    
                    //If no annotation at this location, add annotaion to array
                    let annotation = createNoteAnnotation(noteObject)
                    annotations.append(annotation)
                }
            }
        }
        
        //If searching, remove annotations before adding more
        if searchInput.text != "" {
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
        
        mapView.addAnnotations(annotations)
    }
    
    //Create an annotaion from Note Object
    func createNoteAnnotation(note: NoteObject) -> NoteAnnotation {
        
        //Create new Note Annotation
        let annotation = NoteAnnotation()
        
        //Set annnotation properties
        annotation.coordinate = note.location.coordinate
        annotation.title = note.user.username
        annotation.subtitle = note.locationString
        annotation.note = note
        
        //Return annotation
        return annotation
    }
    
    //Clear search filed
    @IBAction func clearSearchField() {
        searchInput.text = ""
        dismissKeyboard()
        clearButton.hidden = true
        fetchNotesInCurrentArea()
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
