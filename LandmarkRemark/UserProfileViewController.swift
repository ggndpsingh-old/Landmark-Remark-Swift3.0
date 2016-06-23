//
//  UserProfileViewController.swift
//  LandmarkRemark
//
//  Created by Gagandeep Singh on 22/6/16.
//  Copyright © 2016 Gagandeep Singh. All rights reserved.
//

import UIKit
import Parse

class UserProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK:- OURTETS
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var notesCount: UILabel!
    @IBOutlet weak var notesLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK:- VARIABLES
    var refreshControl: UIRefreshControl!
    var notes: [NoteObject]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        //Add refresh control to table view
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(fetchUserNotes), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        fetchUserNotes()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //Prepare view
        self.usernameLabel.text = CurrentUser!.username
        self.notesCount.text = "\(CurrentUser!.notesCount)"
        
        //Populize String
        self.logoutButton.setTitle(NSLocalizedString("LOG_OUT", comment: "Log Out"), forState: .Normal)
        self.notesLabel.text = NSLocalizedString("NOTES", comment: "Notes").lowercaseString
    }
    
    
    //MARK:- TABLE VIEW DELEGATE
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes == nil ? 0 : notes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let note = notes[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("noteCell")!
        
        cell.textLabel?.text = note.note
        cell.detailTextLabel?.text = note.detailsString
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //Change row height accoring to the note
        
        let note = notes[indexPath.row]
        
        //Initiate an option UILabel, which can be nullified later
        var tempLabel: UILabel?
        tempLabel = UILabel(frame: CGRectMake(10, 0, tableView.frame.width - 20, CGFloat.max))
        tempLabel!.numberOfLines = 0
        tempLabel!.font = UIFont.systemFontOfSize(16)
        tempLabel!.text = note.note
        tempLabel!.sizeToFit()
        
        //Compensate for subtitle label
        let height = tempLabel!.frame.height + 20
        tempLabel = nil
        
        return height < 50 ? 50 : height + 10
    }
    
    
    //MARK:- FETCH NOTES
    func fetchUserNotes() {
        
        //Initialize notes array
        notes = [NoteObject]()
        tableView.reloadData()
        
        //Fetch user notes
        let query = PFQuery(className: "Note")
        query.whereKey("user", equalTo: CurrentUser!.parseUser)
        query.includeKey("user")
        query.orderByDescending("createdAt")
        query.findObjectsInBackgroundWithBlock { (objects, error) in
            if let notes = objects {
                for note in notes {
                    self.notes.append(NoteObject(withParseObject: note))
                    self.tableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            }
        }
    }
    
    @IBAction func logout() {
        
        let title = NSLocalizedString("ARE_YOU_SURE", comment: "Location access title")
        
        let alert = UIAlertController(title: title, message: "", preferredStyle: .Alert)
        
        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Cancel"), style: .Cancel, handler: nil)
        let logoutAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("LOG_OUT", comment: "Log Out"), style: .Destructive) { (action) in
            
            //Log Out Parse User
            PFUser.logOut()
            
            //Make Home View active
            self.tabBarController?.selectedIndex = 0
            
            //Go to log in screen
            RootVC.popToRootViewControllerAnimated(true)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(logoutAction)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

}
