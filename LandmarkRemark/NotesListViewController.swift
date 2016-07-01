//
//  NotesListViewController.swift
//  LandmarkRemark
//
//  Created by Gagandeep Singh on 27/6/16.
//  Copyright © 2016 Gagandeep Singh. All rights reserved.
//

import UIKit
import MapKit

class NotesListViewController: UIViewController {
    
    
    //MARK:- OUTLETS
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var notesAtLabel: UILabel!
    
    
    //MARK:- VARIABLES
    
    //Array to hold notes
    var address: String!
    var notes: [NoteObject]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set table view delegate and data source
        tableView.delegate   = self
        tableView.dataSource = self
        
        //Populise Strings
        notesAtLabel.text = NSLocalizedString("NOTES_AT", comment: "Notes at") + ":"
        
        //Remove extra padding on table top
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
        
        NotificationCenter.default().addObserver(self, selector: #selector(reloadTableView), name: "newNoteSaved", object: nil)
        
        let note = self.notes[0]
        let annotaionLocation = note.location.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: annotaionLocation, span: span)
        mapView.setRegion(region, animated: true)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Set Self as Active View Controller
        ActiveViewController = self
        
        addressLabel.text = address

    }
    
    func reloadTableView() {
        self.tableView.reloadData()
    }
    
    
    //MARK:- PREPARE FOR SEGUE
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let editButon = sender as! IndexPathButton
        let indexPath = editButon.indexPath
        let note = notes[indexPath!.row]
        
        let composeVc = segue.destinationViewController as! ComposeViewController
        
        //If editing a Note, set the complete note details
        composeVc.editingNote   = true
        composeVc.noteToEdit    = note
        composeVc.locality      = note.locationString
        composeVc.location      = note.location
    }
    
    @IBAction func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
}


extension NotesListViewController:  UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes == nil ? 0 : notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let note = notes[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteDetailsCell") as! NoteDetailsCell
        
        cell.noteDetailsView.delegate = self
        cell.initialize(withNoteObject: note, atIndexPath: indexPath)
        
        return cell
    }
    
    //MARK:- TABLE VIEW DELEGATE
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //Calculate height for cell accroding to contents of Note
        let note = notes[indexPath.row]
        let height = calculateNoteHeight(note: note)
        
        
        //Compensate for other objects in table cell
        return height + 180
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.backgroundColor = UIColor.clear()
        tableView.backgroundView?.backgroundColor = UIColor.clear()
        cell.backgroundColor = UIColor.clear()
        cell.contentView.backgroundColor = UIColor.clear()
    }
    
    
    //Calculate note height for table view cell
    func calculateNoteHeight(note: NoteObject) -> CGFloat {
        //Initiate an option UILabel, which can be nullified later
        var tempLabel: UILabel?
        tempLabel = UILabel(frame: CGRect(x: 10, y: 0, width: ScreenSize.width - 60, height: CGFloat.greatestFiniteMagnitude))
        tempLabel!.numberOfLines = 0
        tempLabel!.font = UIFont.systemFont(ofSize: 18)
        tempLabel!.text = note.note
        tempLabel!.sizeToFit()
        
        //Compensate for subtitle label
        let height = tempLabel!.frame.height + 20
        tempLabel = nil
        
        return height
    }
    
}


//--------------------------------------------------------------------------------
//MARK:- NoteDetailsView Delegate
//--------------------------------------------------------------------------------
extension NotesListViewController: NoteDetailsViewDelegate {
    
    
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
        
        //Remove deleted note from notes array
        notes = notes.filter({ (note) -> Bool in
            
            if note.objectId == deletedNote.objectId {
                return false
            }
            return true
            
        })
        
        //Update User Notes Count
        CurrentUser!.notesCount = CurrentUser!.notesCount - 1
        CurrentUser!.updateParseUser()
        
        //Reload notes list
        tableView.reloadData()
    }
}
