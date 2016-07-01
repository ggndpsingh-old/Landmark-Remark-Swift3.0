//
//  NoteDetailsCell.swift
//  LandmarkRemark
//
//  Created by Gagandeep Singh on 27/6/16.
//  Copyright © 2016 Gagandeep Singh. All rights reserved.
//

import UIKit

class NoteDetailsCell: UITableViewCell {
    
    
    var note: NoteObject!
    
    //Labels
    @IBOutlet weak var noteDetailsView: NoteDetailsView!
    
    
    //Populize Note Details from Note Object
    func initialize(withNoteObject note: NoteObject, atIndexPath indexPath: NSIndexPath) {
        
        self.note = note
        
        noteDetailsView.initialize(withNoteObject: note)
    }
}
