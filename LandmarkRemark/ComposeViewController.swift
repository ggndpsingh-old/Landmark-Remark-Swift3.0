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

class ComposeViewController: UIViewController, UITextViewDelegate {

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
    var location: CLLocation!
    var locality: String!
    var note: String!
    
    var editingNote = false
    var noteToEdit: NoteObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set delegates
        self.textView.delegate = self
        
        //Start with save button disabled
        saveButton.enabled = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.textView.becomeFirstResponder()
        
        //Add keyboard notification observer
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillChange(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        //Prepapre View
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
    
    
    //MARK:- TEXT VIEW DELEGATE
    func textViewDidChange(textView: UITextView) {
        var note = textView.text!
        let difference = MAX_NOTE_LENGTH - note.characters.count
        
        if note != "" {
            placeholder.hidden = true
            saveButton.enabled = true
            
            characterCounter.text = "\(difference)"
            
            //If text longer than MAX_NOTE_LENGTH is pasted into the text view, remove excess characters
            if difference < 0 {
                for _ in 1 ... 0 - difference {
                    characterCounter.text = "0"
                    note.removeAtIndex(note.endIndex.predecessor())
                    textView.text = note
                }
            }
        
        } else {
            placeholder.hidden = false
            saveButton.enabled = false
            characterCounter.text = "\(MAX_NOTE_LENGTH)"
        }
    }
    
    
    //MARK:- KEYBOARD NOTIFICATIONS
    func keyboardWillChange(notification : NSNotification) {
        
        //Keep toolbar on top of the keyboard
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
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
    
    
    //MARK:- SAVE NOTE
    @IBAction func saveNote(sender: AnyObject) {
        
        showProcessing()
        
        //If editing note
        if editingNote {
            
            noteToEdit.note = textView.text!
            noteToEdit.updateParseObject()
            
            noteToEdit.parseObject.saveInBackgroundWithBlock({ (success, error) in
                if success {
                    showMessageView(NSLocalizedString("NOTE_SAVED", comment: "Note saved"), valid: true, completion: { (success) in
                        
                        //Notify map view to update notes
                        NSNotificationCenter.defaultCenter().postNotificationName("newNoteSaved", object: nil)
                        
                        self.dismiss()
                        self.hideProcessing()
                    })
                
                } else {
                    showMessageView(NSLocalizedString("NOTE_NOT_SAVED", comment: "Note not saved"), valid: false, completion: nil)
                    self.hideProcessing()
                }
            })
        
        } else {
            
            //Create a new Note Object
            let note = NoteObject()
            
            //Add note values
            note.note = textView.text!
            note.user = CurrentUser!
            note.location = location
            note.locationString = locality
            
            note.saveAsNewNote { (success) in
                if success {
                    showMessageView(NSLocalizedString("NOTE_SAVED", comment: "Note saved"), valid: true, completion: { (success) in
                        //Update user notes count
                        CurrentUser!.notesCount = CurrentUser!.notesCount + 1
                        CurrentUser!.updateParseUser()
                        
                        //Notify map view to update notes
                        NSNotificationCenter.defaultCenter().postNotificationName("newNoteSaved", object: nil)
                        
                        self.dismiss()
                        self.hideProcessing()
                    })
                    
                } else {
                    showMessageView(NSLocalizedString("NOTE_NOT_SAVED", comment: "Note not saved"), valid: false, completion: nil)
                    self.hideProcessing()
                }
            }
        }
    }
    
    //MARK:- PROCESSING VIEWS
    func showProcessing() {
        //Called when save button is tapped
        view.endEditing(true)
        
        //Show progress
        spinner.startAnimating()
        
        //Cannot dismiss view while processing
        closeButton.hidden = true
        
        //Disable save button
        saveButton.enabled = false
        saveButton.alpha = 0.5
        
        //Disable text view to disallow further changes
        textView.editable = false
    }
    
    func hideProcessing() {
        
        spinner.stopAnimating()
        closeButton.hidden = false
        saveButton.enabled = true
        saveButton.alpha = 1
        textView.editable = true
    }
    
    @IBAction func dismiss() {
        editingNote = false
        self.view.endEditing(true)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        //Remove keyboard notification observers
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillChangeFrameNotification, object: nil)
        
    }

}
