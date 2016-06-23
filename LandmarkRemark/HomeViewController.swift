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
    var locationManager: CLLocationManager!
    var location : CLLocation!
    var lastLocation: CLLocation!
    var locality: String!
    
    var noteObjects: [PFObject]!
    var notes: [NoteObject]!
    var selectedNote: NoteObject?
    
    var tap: UITapGestureRecognizer!

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
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        manager.startUpdatingLocation()
    }
    
    func reloadNotes() {
        fetchNotesInCurrentArea()
        goToCurrentLocation()
    }
    
    //MARK:- LOCATION MANAGER DELEGATE
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.location = locations[0]
        self.lastLocation = locations[0]
        
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(manager.location!) { (placemarks, error) -> Void in
            if error == nil {
                if placemarks!.count > 0 {
                    self.getLocationInfo(placemarks![0] as CLPlacemark)
                }
            } else {
                print(error)
            }
        }
    }
    
    
    func getLocationInfo(placemark : CLPlacemark) {
        
        //Get location details
        if let addressDictionary: NSDictionary = placemark.addressDictionary {
            let strings = addressDictionary["FormattedAddressLines"]
            self.locality = strings!.componentsJoinedByString(" ")
            
        } else {
            
            let subLocality = placemark.subLocality == nil ? "" : placemark.subLocality!
            let locality    = placemark.locality    == nil ? "" : placemark.locality!
            let postcode    = placemark.postalCode  == nil ? "" : placemark.postalCode!
            let country     = placemark.country     == nil ? "" : placemark.country!
            
            let string = "\(subLocality) \(locality) \(postcode) \(country)"
            self.locality = string
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
    
    @IBAction func deselectAnnotationView() {
        mapView.deselectAnnotation(mapView.selectedAnnotations[0], animated: true)
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
            composeVc.locality      = self.locality
            composeVc.location      = self.location
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
        spinner.startAnimating()
        clearButton.hidden = true
        
        let searchText = self.searchInput.text!
        let regex : String = "(?i:\(searchText))"
        
        let geoPoint = PFGeoPoint(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
        noteObjects = [PFObject]()
        
        let query = PFQuery(className: "Note")
        
        //If search input is empty, this statement will return all the results
        query.whereKey("searchString", matchesRegex: regex)
        
        //Search within the visible area only
        query.whereKey("location", nearGeoPoint: geoPoint, withinKilometers: getMapViewRadius())
        
        
        query.includeKey("user")
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if let notes = objects {
                self.noteObjects = notes
                self.addNoteAnnotations()
            }
            self.spinner.stopAnimating()
            
            if searchText != "" {
                //If searching, show clear button
                self.clearButton.hidden = false
            }
        }
    }
    
    func addNoteAnnotations() {
        notes = [NoteObject]()
        var annotations = [NoteAnnotation]()
        
        for note in noteObjects {
            let noteObject = NoteObject(withParseObject: note)
            
            if self.notes.indexOf({$0.objectId == noteObject.objectId}) == nil {
                self.notes.append(noteObject)
                annotations.append(createNoteAnnotation(noteObject))
            }
        }
        
        //If searching, remove annotations before adding more
        if searchInput.text != "" {
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
        mapView.addAnnotations(annotations)
    }
    
    func createNoteAnnotation(note: NoteObject) -> NoteAnnotation {
        
        let annotation = NoteAnnotation()
        annotation.coordinate = note.location.coordinate
        annotation.title = note.user.username
        annotation.subtitle = note.locationString
        annotation.note = note
        return annotation
    }
    
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
