//
//  NoteDetailsView.swift
//  LandmarkRemark
//
//  Created by Gagandeep Singh on 27/6/16.
//  Copyright © 2016 Gagandeep Singh. All rights reserved.
//

import UIKit

public protocol NoteDetailsViewDelegate: class {
    
    func showNoteOptions(forNote: NoteObject)
    func editNote(note: NoteObject)
    func deleteNote(note: NoteObject)
    func noteDeleted(deletedNote: NoteObject)
    
}

//A UIView for Note Details that can be used throughout the app
@IBDesignable class NoteDetailsView: UIView {
    
    
    //Main UIView for Note Details
    var view:UIView!;
    
    //Note to Display
    var note: NoteObject!
    
    //All notes at the Note Address
    var allNotesAtAddress: [NoteObject]?
    
    //Set delegate
    var delegate: NoteDetailsViewDelegate?
    
    
    @IBOutlet weak var noteLabel:           UILabel!
    @IBOutlet weak var usernameLabel:       UILabel!
    @IBOutlet weak var locationLabel:       UILabel!
    @IBOutlet weak var dateLabel:           UILabel!
    @IBOutlet weak var showAllNotesButton:  UIButton!
    @IBOutlet weak var likesLabel:          UILabel!
    @IBOutlet weak var optionsButton:       UIButton!
    @IBOutlet weak var likeButton:          LikeButton!
    
    
    //-----------------------------------------------------------------------------
    //MARK:- Initialize
    //  Note Details View can be initialized from both Storyboard and Code
    //-----------------------------------------------------------------------------
    
    override init(frame: CGRect) {
        //properties
        super.init(frame: frame)
        
        //setup
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        //properties
        super.init(coder: aDecoder)
        
        //setup
        setup ()
    }
    
    //-----------------------------------------------------------------------------
    //MARK:- Set up view
    //-----------------------------------------------------------------------------
    func setup() {
        view = createViewFromNib()
        
        //Set View Bounds & Resizing
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        //Add view to main view
        self.addSubview(view);
        
        showAllNotesButton.addTarget(self, action: #selector(self.goToNotesAtLocation), for: .touchUpInside)
    }
    
    
    //-----------------------------------------------------------------------------
    //MARK:- Create view
    //-----------------------------------------------------------------------------
    func createViewFromNib() -> UIView {
        let bundle = Bundle(for: self.dynamicType)
        let nib = UINib(nibName: "NoteDetailsView", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    
    
    
    //-----------------------------------------------------------------------------
    //MARK:- Initializer to populize view with Note Details
    //-----------------------------------------------------------------------------
    func initialize(withNoteObject note: NoteObject) {
        
        //Add listener for the Like Button
        NotificationCenter.default().addObserver(self, selector: #selector(self.updateLikes), name: "likesCountChanged", object: nil)
        
        //Add listener for Note Edited Notification
        NotificationCenter.default().addObserver(self, selector: #selector(self.noteEdited), name: "noteEdited", object: nil)
        
        
        //Set Note Object
        self.note = note
        
        //Populize View
        usernameLabel.text  = note.user.username!
        locationLabel.text  = note.locationString!
        dateLabel.text      = note.createdAt!.dateOnlyFormat()
        noteLabel.text      = note.note!
        likesLabel.text     = "\(note.likes!) Likes"
        
        
        //Setup Like Button
        likeButton.initialize(note: note)
        
        //Show all notes button should only be visible if there are more than 1 note at the given address and the note is being displayed at Landmarks View Controller
        if ActiveViewController is LandmarksViewController && allNotesAtAddress!.count > 1 {
            
            showAllNotesButton.setTitle(generateString(forNotesCount: allNotesAtAddress!.count), for: [])
            showAllNotesButton.isHidden = false
            
        } else {
            showAllNotesButton.isHidden = true
        }
        
        //Show options button only if Current User is Note Author
        optionsButton.isHidden = note.user.username != CurrentUser!.username
    }
    
    //-----------------------------------------------------------------------------
    //MARK:- Update Labels
    //-----------------------------------------------------------------------------
    func updateLikes() {
        likesLabel.text     = "\(note.likes!) Likes"
    }
    
    
    func noteEdited() {
        noteLabel.text = note.note!
    }
    
    //-----------------------------------------------------------------------------
    //MARK:- Segue to Notes List View Controller
    //-----------------------------------------------------------------------------
    func goToNotesAtLocation() {
        let destVc = MainStoryboard.instantiateViewController(withIdentifier: "NotesListViewController") as! NotesListViewController
        
        destVc.notes = allNotesAtAddress
        destVc.address = note!.locationString
        
        ActiveViewController?.present(destVc, animated: true, completion: nil)
    }
    
    
    
    //-----------------------------------------------------------------------------
    //MARK:- User actions on the UI
    //-----------------------------------------------------------------------------
    @IBAction func showNoteOptions(sender: UIButton) {
        
        delegate?.showNoteOptions(forNote: self.note)
        
    }
    
    
    //-----------------------------------------------------------------------------
    //MARK:- Helper Methods
    //-----------------------------------------------------------------------------
    func clearNoteView() {
//        self.note = nil
        
        usernameLabel.text  = ""
        locationLabel.text  = ""
        dateLabel.text      = ""
        noteLabel.text      = ""
    }
    
}
