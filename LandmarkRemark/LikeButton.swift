//
//  LikeButton.swift
//  LandmarkRemark
//
//  Created by Gagandeep Singh on 28/6/16.
//  Copyright © 2016 Gagandeep Singh. All rights reserved.
//

import UIKit

class LikeButton: UIButton {
    
    var note : NoteObject!
    var isLiked = false
    
    //init
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    //Setup Like Button
    func initialize(note: NoteObject) {
        self.note = note
        
        //Setup Button Status
        note.likedBy.contains(CurrentUser!.username) ? self.liked() : self.unLiked()
        
        //Add target method
        addTarget(self, action: #selector(likeNote), for: .touchUpInside)
    }
    
    //Like Note Method
    func likeNote() {
        
        //If the Note is NOT currently liked
        if !isLiked {
            
            //Change button state to Liked
            self.liked()
            
            //Update Likes and Likes Count
            note.likedBy.insert(CurrentUser!.username, at: 0)
            note.likes = note.likedBy.count
            
            //Update Object in Database
            note.updateParseObject()
            
            //Save user to Database
            note.parseObject.saveInBackground({ (success, error) -> Void in
                if !success {
                    
                    //If like fails, restore button to unliked state
                    self.unLiked()
                }
            })
            
        } else {
            //If the note IS Liked
            
            //Change button state to Unliked
            self.unLiked()
            
            //Remove username from Note Likes
            note.likedBy = note.likedBy.filter() { $0 != CurrentUser!.username }
            
            //Update Likes and Likes Count
            note.likes = note.likedBy.count
            
            //Update Object in Database
            note.updateParseObject()
            
            //Save user to Database
            note.parseObject.saveInBackground({ (success, error) -> Void in
                if !success {
                    
                    //If unlike fails, restore button to liked state
                    self.liked()
                }
            })
        }
        
        //Animate Button
        animateButton()
        
        //Update Note Details View
        NotificationCenter.default().post(name: "likesCountChanged" as NSNotification.Name, object: nil)
    }
    
    func animateButton() {
        
        //Show a size bounce animation
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.transform = CGAffineTransform.identity.scaleBy(x: 1.1, y: 1.1)
            
        }) { (finished) -> Void in
            UIView.animate(withDuration: 0.08, animations: { () -> Void in
                self.transform = CGAffineTransform.identity.scaleBy(x: 0.9, y: 0.9)
                
                }, completion: { (finished) -> Void in
                    UIView.animate(withDuration: 0.08, animations: { () -> Void in
                        self.transform = CGAffineTransform.identity
                        
                        }, completion: nil)
            })
        }
    }
    
    
    //Change Button state methods
    func liked() {
        isLiked = true
        setImage(UIImage(named: "icon-liked"), for: [])
    }
    
    func unLiked() {
        isLiked = false
        setImage(UIImage(named: "icon-like"), for: [])
    }
    
}
