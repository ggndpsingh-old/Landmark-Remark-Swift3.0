//
//  LandmarksViewController.swift
//  LandmarkRemark
//
//  Created by Gagandeep Singh on 22/6/16.
//  Copyright © 2016 Gagandeep Singh. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import MapKit
import AddressBookUI

class LandmarksViewController: UIViewController, LandmarksViewModelDelegate {
    
    //MARK:- OUTLETS
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var noteDetailsContainer: UIView!
    @IBOutlet weak var noteViewBottomLayout: NSLayoutConstraint!
    @IBOutlet weak var noteDetailsView: NoteDetailsView!
    
    @IBOutlet weak var searchInput: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var composeButton: UIButton!
    
    
    //MARK:- VARIABLES
    
    //initialize Landmark View Model
    var viewModel: LandmarksViewModel!
    
    //initialize Landmark Service
    var landmarkService: LandmarksService!
    
    //init location manager
    var locationManager: CLLocationManager!
    
    //user current locations
    var currentLocation : CLLocation!
    
    //save last location whenever map region changes
    var lastLocation: CLLocation!
    
    //Location String
    var locationString: String!
    
    //Note Objects
    var noteObjects: [NoteObject]!
    
    //Notes Separated by Address
    //Will be used to show related notes at the same address when a note is selected
    var notesSeparatedByAddress: NSDictionary!
    
    //Notes At current address
    var notesAtCurrentAddress: [NoteObject]!
    
    //Selected Note
    var selectedNote: NoteObject?
    
    //tap to dismiss keyboard
    var tap: UITapGestureRecognizer!

    //Segue Identifiers
    enum SegueIdentifiers: String {
        case NotesList = "showNotesAtAddress"
        case ComposeNote = "composeNote"
    }
    
    
    
    
    //------------------------------------------------------------------------------------------------
    //MARK: - View controller life cycle methods
    //------------------------------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        viewModel = LandmarksViewModel(delegate: self)
        landmarkService = LandmarksService()
        
        //Set Note Details View Delegate
        noteDetailsView.delegate = self
        
        //Setup Location Manager
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
        
        //Setup Map View
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = MKUserTrackingMode.follow
        
        //Setup Search Input
        searchInput.delegate = self
        searchInput.addTarget(self, action: #selector(textFieldDidChange(textField: )), for: UIControlEvents.editingChanged)
        searchInput.backgroundColor = UIColor.black().withAlphaComponent(0.02)
        
        //Setup Tap
        tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        NotificationCenter.default().addObserver(self, selector: #selector(self.showSavedNote(notification:)), name: "newNoteSaved", object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Set Self as Active View Controller
        ActiveViewController = self
        
        //Set Shadows
        
        currentLocationButton.layer.shadowColor = UIColor.black().cgColor
        currentLocationButton.layer.shadowRadius = 2
        currentLocationButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        currentLocationButton.layer.shadowOpacity = 0.2
        
        //Make sure Map View doesnt cover any other views
        view.sendSubview(toBack: mapView)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Hide note detials view before leaving view
        if mapView.selectedAnnotations.count > 0 {
            mapView.deselectAnnotation(mapView.selectedAnnotations[0], animated: true)
        }
    }
    
    
    
    func getMapViewRadius() -> CLLocationDistance {
        
        //Calculate the area of map on screen
        
        //Get location at the center of the map
        let centerCoordinates = mapView.centerCoordinate
        let centerLocation = CLLocation(latitude: centerCoordinates.latitude, longitude: centerCoordinates.longitude)
        
        //Get location at the top of the map
        let topCenterCoordinates = mapView.convert(CGPoint(x: self.mapView.frame.size.height/2, y: 0), toCoordinateFrom: mapView)
        let topCenterLocation = CLLocation(latitude: topCenterCoordinates.latitude, longitude: topCenterCoordinates.longitude)
        
        //Calculate distance from Center of map to Top of map
        let radius: CLLocationDistance = centerLocation.distance(from: topCenterLocation)
        let radiusInKilometers = convertMetersToKilometers(distance: radius)
        
        //Return distance
        return radiusInKilometers
    }
    
    
    // -------------------------------
    //MARK:- user Actions on the UI
    // -------------------------------
    @IBAction func deselectAnnotationView() {
        mapView.deselectAnnotation(mapView.selectedAnnotations[0], animated: true)
    }
    
    @IBAction func goToCurrentLocation() {
        mapView.setCenter(mapView.userLocation.coordinate, animated: true)
    }
    
    //Clear search filed
    @IBAction func clearSearchField() {
        searchInput.text = ""
        dismissKeyboard()
        clearButton.isHidden = true
        fetchNotesInCurrentArea()
    }
    
    
    
    
    // -----------------------------------------------------------------------------------------------------
    //MARK:- Segue Methods
    // -----------------------------------------------------------------------------------------------------
    override func shouldPerformSegue(withIdentifier identifier: String, sender: AnyObject?) -> Bool {
        
        //Check Location Authorization and show alerts if Not Authorised
        getLocationAuthorization()
        
        //Perform segue only if Authorized
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            if sender as? UIButton == noteDetailsView.showAllNotesButton {
                deselectAnnotationView()
            }
            return true
        }
        
        return false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        
        //Prepare for segue to Compose View
        let composeVc = segue.destinationViewController as! ComposeViewController
        
        switch segue.identifier! {
        case "showNotesAtAddress":
            let listVc = segue.destinationViewController as! NotesListViewController
            listVc.notes = notesAtCurrentAddress
            
        default:
            composeVc.locality      = self.locationString
            composeVc.location      = self.currentLocation
        }
    }
    
    
    //Reload notes if required
    func showSavedNote(notification: NSNotification) {
        let note = notification.userInfo?["note"] as! NoteObject
        
        // Center map on saved note location
        mapView.centerCoordinate = note.location.coordinate
        
        // Fetch notes in visible area
        fetchNotesInCurrentArea()
    }
    
    
    
    
    // -----------------------------------------------------------------------------------------------------
    //MARK:- LandmarksViewModelDelegate method implementation, called by the view-model to notify anything
    // -----------------------------------------------------------------------------------------------------
    func updateMapView(withAnnotations annotations: [NoteAnnotation]) {
        for annotation in annotations {
            if !landmarkService.annotationExists(atCoordinates: annotation.coordinate, inMapView: mapView) {
                
                mapView.addAnnotation(annotation)
                
            }
        }
        
    }
    
    func resetMapView(withAnnotations annotations: [NoteAnnotation]) {
        for annotation in mapView.annotations {
            if !(annotation is MKUserLocation) {
                mapView.removeAnnotation(annotation)
            }
        }
        mapView.addAnnotations(annotations)
    }
    
    func fetchNotesInCurrentArea() {
        let centerCoordinate = mapView.centerCoordinate
        let radius = getMapViewRadius()
        let searchString = searchInput.text!
        
        viewModel.loadNotes(nearLocation: centerCoordinate, withinRadius: radius, forString: searchString)
    }
    
    func showLoading() {
        spinner.startAnimating()
        clearButton.isHidden = true
    }
    
    func hideLoading() {
        spinner.stopAnimating()
        if searchInput.text != "" {
            clearButton.isHidden = false
        }
    }
    
    
    
    
    //------------------------------------------------------------------------------------------------
    // MARK: - Location Authorizations methods
    //------------------------------------------------------------------------------------------------
    func getLocationAuthorization() {
        let status: CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            
        case .restricted:
            showRestrictedAuthorizationAlert()
            
        case .denied:
            showDeniedAuthorizationAlert()
            
        default:
            break;
        }
        
    }
    
    //Show alert if user has denied Location Access
    func showDeniedAuthorizationAlert() {
        let title = NSLocalizedString("LOCATION_ACCESS_TITLE", comment: "Location access title")
        let message = NSLocalizedString("LOCATION_ACCESS_MESSAGE", comment: "Location access message")
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"), style: .cancel, handler: nil)
        let settingsAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("SETTINGS", comment: "Settings"), style: .default) { (action) in
            
            UIApplication.shared().open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(settingsAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    //Show alert if user lcoation is restricted on device
    func showRestrictedAuthorizationAlert() {
        let title = NSLocalizedString("LOCATION_RESTRICTED_TITLE", comment: "Location restricted title")
        let message = NSLocalizedString("LOCATION_RESTRICTED_MESSAGE", comment: "Location restricted message")
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
}




//----------------------------------------------
// MARK: - CLLocationManagerDelegate
//----------------------------------------------
extension LandmarksViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        manager.startUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //Set current Location and last Location on location change
        currentLocation = locations[0]
        lastLocation = locations[0]
        
        //get location information
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(manager.location!) { (placemarks, error) -> Void in
        
            
            if error == nil {
            
                if placemarks!.count > 0 {
                    
                    //Get address string for location
                    self.getLocationInfo(placemark: placemarks![0] as CLPlacemark)
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
            locationString = strings!.componentsJoined(by: " ")
            
        } else {
            
            let subLocality = placemark.subLocality == nil ? "" : placemark.subLocality!
            let locality    = placemark.locality    == nil ? "" : placemark.locality!
            let postcode    = placemark.postalCode  == nil ? "" : placemark.postalCode!
            let country     = placemark.country     == nil ? "" : placemark.country!
            
            let string = "\(subLocality) \(locality) \(postcode) \(country)"
            locationString = string
        }
        
    }
    
}




//---------------------------------------------------
// MARK: - MKMapViewDelegate
//---------------------------------------------------
extension LandmarksViewController: MKMapViewDelegate {

    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        //Update notes when region changes
        fetchNotesInCurrentArea()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let view = MKAnnotationView(annotation: annotation, reuseIdentifier: "annotationView")
        view.image = UIImage(named: "icon-location-pin")
        view.canShowCallout = true
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor.white()
        label.text = "2"
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.boldSystemFont(ofSize: 12)
//        view.addSubview(label)
        
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let annotaionLocation = view.annotation!.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: annotaionLocation, span: span)
        
        if mapView.region.span.latitudeDelta > region.span.latitudeDelta {
        
            mapView.setRegion(region, animated: true)
        }
        
        //Show note details when a pin is selected
        if let annotation = view.annotation as? NoteAnnotation {
            selectedNote = annotation.note
            
            //Populize note details
            noteDetailsView.allNotesAtAddress = viewModel.fetchNotes(atAddress: selectedNote!.locationString)
            noteDetailsView.initialize(withNoteObject: selectedNote!)
            
            //Present note details
            UIView.animate(withDuration: 0.2) {
                self.noteViewBottomLayout.constant = 0
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        
        //Reset note details view
//        noteDetailsView.clearNoteView()
        
        //Hide note details view
        UIView.animate(withDuration: 0.2) {
            self.noteViewBottomLayout.constant = 0 - self.noteDetailsView.frame.height
            self.view.layoutIfNeeded()
        }
    }
    
}


//---------------------------------------------------
// MARK: - UITextFieldDelegate
//---------------------------------------------------
extension LandmarksViewController: UITextFieldDelegate {

    func textFieldDidBeginEditing(_ textField: UITextField) {
        view.addGestureRecognizer(tap)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        view.removeGestureRecognizer(tap)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
     @objc func textFieldDidChange(textField: UITextField) {
        //Perform search based on input
        self.fetchNotesInCurrentArea()
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}






//--------------------------------------------------------------------------------
//MARK:- NoteDetailsView Delegate
//--------------------------------------------------------------------------------
extension LandmarksViewController: NoteDetailsViewDelegate {
    
    //MARK: Show Note Options
    func showNoteOptions(forNote note: NoteObject) {
        
        //Create Action Sheet for Edit & Delete optiions
        let actionSheet: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let editAction = UIAlertAction(title: NSLocalizedString("EDIT", comment: "Edit"), style: .default) { (action) in
            //Edit Segue
            self.editNote(note: note)
        }
        
        let deleteAction = UIAlertAction(title: NSLocalizedString("DELETE", comment: "Delete"), style: .destructive) { (action) in
            self.deleteNote(note: note)
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"), style: .cancel, handler: nil)
        
        actionSheet.addAction(editAction)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
        
        //Show Action Sheet
        present(actionSheet, animated: true, completion: nil)
    }
    
    
    //MARK: Edit Note
    func editNote(note: NoteObject) {
        
        //Set Destination View Controller as Compose View Controller
        let destVc = MainStoryboard.instantiateViewController(withIdentifier: "ComposeViewController") as! ComposeViewController
        
        //Setup Compose View Controller variables
        destVc.editingNote = true
        destVc.noteToEdit = note
        destVc.locality = note.locationString
        
        //Persent Compose View Controller
        present(destVc, animated: true, completion: nil)
    }
    
    
    //MARK: Delete Note
    func deleteNote(note: NoteObject) {
        
        //Show alert to confim
        let alertView: UIAlertController = UIAlertController(title: NSLocalizedString("ARE_YOU_SURE", comment: "Are you sure?"), message: nil, preferredStyle: .alert)
        
        //Add Delete Action
        let deleteAction = UIAlertAction(title: NSLocalizedString("DELETE", comment: "Delete"), style: .destructive) { (action) in
            
            //Delete note on Database
            note.deleteNote(completion: { (success, error) in
                
                if success {
                    //If note deleted, update UI
                    self.noteDeleted(deletedNote: note)
                
                } else {
                    //Show error message
                    showMessageView(message: NSLocalizedString("NOTE_NOT_DELETED", comment: "Note not deleted"), valid: false, completion: nil)
                }
            })
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"), style: .cancel, handler: nil)
        
        alertView.addAction(cancelAction)
        alertView.addAction(deleteAction)
        
        present(alertView, animated: true, completion: nil)
    }
    
    
    
    //MARK: Note Deleted
    func noteDeleted(deletedNote: NoteObject) {
        
        // Remove all annotation at the same address as of deleted annotations
        // If this is not done, the remaining annoataions at same address will show the old count for annotations at the address.
        
        for annotation in mapView.annotations {
            if annotation is NoteAnnotation {
                let thisAnnotation = annotation as! NoteAnnotation
                
                if thisAnnotation.note.locationString == deletedNote.locationString {
                    mapView.removeAnnotation(thisAnnotation)
                }
            }
        }
        
        //Update User Notes Count
        CurrentUser!.notesCount = CurrentUser!.notesCount - 1
        CurrentUser!.updateParseUser()
        
        // Reload notes in visible area
        fetchNotesInCurrentArea()
     
    }
}
