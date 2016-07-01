//
//  ComposeViewController.swift
//  LandmarkRemark
//
//  Created by Gagandeep Singh on 22/6/16.
//  Copyright © 2016 Gagandeep Singh. All rights reserved.
//

import UIKit
import CoreLocation
import Parse

class ComposeViewController: UIViewController, UITextViewDelegate, ComposeViewModelDelegate {

    //MARK:- OUTLETS
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var toolbar: UIView!
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var placeholder: UILabel!
    
    @IBOutlet weak var characterCounter: UILabel!
    
    //MAR:- VARIABLES
    
    var viewModel: ComposeViewModel!
    
    var location: CLLocation!
    var locality: String!
    var note: String!
    
    var editingNote = false
    var noteToEdit: NoteObject!
    
    
    
    
    //------------------------------------------------------------------------------------------------
    // MARK: - View controller life cycle methods
    //------------------------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = ComposeViewModel(delegate: self)
        
        //Set delegates
        self.textView.delegate = self
        
        //Start with save button disabled
        saveButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Set Self as Active View Controller
        ActiveViewController = self
        
        self.textView.becomeFirstResponder()
        
        //Add keyboard notification observer
        NotificationCenter.default().addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default().addObserver(self, selector: #selector(self.keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        //Prepare View
        usernameLabel.text = CurrentUser!.username
        locationLabel.text = self.locality
        characterCounter.text = "\(MAX_NOTE_LENGTH)"
        
        saveButton.layer.cornerRadius = 5
        saveButton.clipsToBounds = true
        
        //If editing a note
        if editingNote {
            self.textView.text = noteToEdit.note
            
            //Force text field change to update character count
            textViewDidChange(textView)
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //Remove keyboard notification observers
        NotificationCenter.default().removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default().removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
    }
    
    
    
    
    //------------------------------------------------------------------------------------------------
    // MARK: - UITextViewDelegate Methods
    //------------------------------------------------------------------------------------------------
    func textViewDidChange(_ textView: UITextView) {
        var note = textView.text!
        let difference = MAX_NOTE_LENGTH - note.characters.count
        
        if note != "" {
            placeholder.isHidden = true
            saveButton.isEnabled = true
            
            characterCounter.text = "\(difference)"
            
            //If text longer than MAX_NOTE_LENGTH is pasted into the text view, remove excess characters
            if difference < 0 {
                for _ in 1 ... 0 - difference {
                    characterCounter.text = "0"
                    note.remove(at: note.index(before: note.endIndex))
                    textView.text = note
                }
            }
        
        } else {
            placeholder.isHidden = false
            saveButton.isEnabled = false
            characterCounter.text = "\(MAX_NOTE_LENGTH)"
        }
    }
    
    
    
    
    
    //------------------------------------------------------------------------------------------------
    // MARK: - Keyboard Notifications
    //------------------------------------------------------------------------------------------------
    func keyboardWillChange(notification : NSNotification) {
        
        //Keep toolbar on top of the keyboard
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue() {
            self.toolbarBottomConstraint.constant = keyboardSize.height
        }
    }
    
    func keyboardWillHide(notification : NSNotification) {
        //Restore toolbar to bottom of the view
        self.toolbarBottomConstraint.constant = 0
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    
    // -------------------------------
    // MARK :- user Actions on the UI
    //
    @IBAction func saveNote(sender: AnyObject) {
        
        showProcessing()
        
        //If editing note
        if editingNote {
            
            let newBody = textView.text!
            viewModel.updateNote(note: self.noteToEdit, withBody: newBody)
            
        } else {
            
            //Create a new Note Object
            let note = textView.text!
            let location = self.location
            let locationString = locality

            viewModel.createNewNote(withBody: note, forUser: CurrentUser!, atLocation: location!, withAddress: locationString!)
            
        }
    }
    
    @IBAction func dismiss() {
        editingNote = false
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    // -------------------------------------------------------------------------------------------------------
    // MARK :- ComposeViewModelDelegate method implementation, called by the view-model to notify anything
    // -------------------------------------------------------------------------------------------------------
    func noteSavedSuccessfully(note: NoteObject) {
        
        //Notify map view to update notes
        NotificationCenter.default().post(name: "newNoteSaved" as NSNotification.Name, object: nil, userInfo: ["note": note])
        
        //Show success message
        showMessageView(message: NSLocalizedString("NOTE_SAVED", comment: "Note saved"), valid: true, completion: { (success) in
            
            //Dismiss View Controller
            self.dismiss()
            
        })
    }
    
    func noteEditedSuccessfully(note: NoteObject) {
        
        //Notify Note Details View to update Note Label
        NotificationCenter.default().post(name: "noteEdited" as NSNotification.Name, object: nil, userInfo: ["note": note])
        
        //Show success message
        showMessageView(message: NSLocalizedString("NOTE_SAVED", comment: "Note saved"), valid: true, completion: { (success) in
            
            //Dismiss View Controller
            self.dismiss()
            
        })
    }
    
    func noteNotSaved() {
        showMessageView(message: NSLocalizedString("NOTE_NOT_SAVED", comment: "Note not saved"), valid: false, completion: nil)
    }
    
    
    func showProcessing() {
        //Called when save button is tapped
        view.endEditing(true)
        
        //Show progress
        spinner.startAnimating()
        
        //Cannot dismiss view while processing
        closeButton.isHidden = true
        
        //Disable save button
        saveButton.isEnabled = false
        saveButton.alpha = 0.5
        
        //Disable text view to disallow further changes
        textView.isEditable = false
    }
    
    func hideProcessing() {
        
        spinner.stopAnimating()
        closeButton.isHidden = false
        saveButton.isEnabled = true
        saveButton.alpha = 1
        textView.isEditable = true
    }

}
