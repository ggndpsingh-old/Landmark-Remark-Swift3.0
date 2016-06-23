//
//  VerifyEmailViewController.swift
//  LandmarkRemark
//
//  Created by Gagandeep Singh on 21/6/16.
//  Copyright © 2016 Gagandeep Singh. All rights reserved.
//

import UIKit

class VerifyEmailViewController: UIViewController, UITextFieldDelegate {
    
    //MARK:- OUTLETS
    @IBOutlet weak var signUpTitle: UILabel!
    @IBOutlet weak var emailInput: TranslucentTextField!
    @IBOutlet weak var nextButton: LargeWhiteButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    //MARK:- VARIABLES
    var email: String!
    var tap: UITapGestureRecognizer!
    
    //MARK:- METHODS
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Start with Next Button disabled
        nextButton.disabled()
        
        //Tap to dismiss keyboard
        self.tap = UITapGestureRecognizer()
        self.tap.addTarget(self, action: #selector(dismissKeyboard))
        
        //Prepare View
        setViewBackground()
        populizeStrings()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.emailInput.delegate = self
        
        //Add Keyboard Notification Observers
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillChange(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        emailInput.addTarget(self, action: #selector(textFieldDidChange(_:)), forControlEvents: .EditingChanged)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.emailInput.becomeFirstResponder()
    }
    
    
    //MARK:- PREPARE VIEW
    func setViewBackground() {
        //Set the gradient for background
        self.view.layer.insertSublayer(purpleGradient(), atIndex: 0)
    }
    
    func populizeStrings() {
        self.signUpTitle.text = NSLocalizedString("SIGN_UP", comment: "Sign Up")
        self.emailInput.placeholder = NSLocalizedString("EMAIL_ADDRESS", comment: "Email Address")
        self.nextButton.setTitle(NSLocalizedString("NEXT", comment: "Next"), forState: .Normal)
        
    }
    
    
    //MARK:- TEXT FIELD DELEGATE
    func textFieldDidBeginEditing(textField: UITextField) {
        view.addGestureRecognizer(tap)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        view.removeGestureRecognizer(tap)
    }
    
    func textFieldDidChange(textField: UITextField) {
        textField.text == "" ? nextButton.disabled() : nextButton.enabled()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.verifyEmail(nextButton)
        view.endEditing(true)
        return true
    }
    
    
    //MARK:-  KEYBOARD NOTIFICATIONS
    func keyboardWillChange(notification: NSNotification) {
        if let keyboardRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            
            let keyboardOrigin = keyboardRect.origin.y
            let buttonMaxY = CGRectGetMaxY(nextButton.frame)
            
            // If keyboard overlaps the button
            if keyboardOrigin < buttonMaxY {
                //Move view up
                self.view.frame.origin.y = 0 - (buttonMaxY - keyboardOrigin) - MIN_KEYBOARD_DISTANCE
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    //MARK:- VERIFY EMAIL
    @IBAction func verifyEmail(sender: UIButton) {
        
        let email = self.emailInput.text!
        //Validate email
        if isValidEmail(email) {
            
            //Valid Email
            self.email = email
            showProcessing()
            
            //Check if email already exists in database
            checkAvailabilityInUserClass(inField: "email", forValue: email, completion: { (available) in
                if available {
                    //Can use email for Sign Up, continue Sign Up
                    self.performSegueWithIdentifier("goToSignUp", sender: self)
                    
                } else {
                    //Another account is using the given email
                    showMessageView("\(NSLocalizedString("ANOTHER_ACCOUNT_IS_USING", comment: "Another account is using")) '\(email)'", valid: false, completion: { (success) in
                        self.emailInput.invalid()
                        self.emailInput.becomeFirstResponder()
                    })
                }
                
                self.hideProcessing()
            })
        
        } else {
            //Invalid Email
            showMessageView(NSLocalizedString("INVALID_EMAIL", comment: "Invalid Email"), valid: false, completion: nil)
        }
    }
    
    //MARK:- LOGIN PROCESSING STATES
    func showProcessing() {
        dismissKeyboard()
        
        //Show spinner on top of login button
        spinner.startAnimating()
        nextButton.disabled()
        
        //Hides Log In text and leaves the border intact for a better look
        nextButton.setTitle("", forState: .Normal)
    }
    
    func hideProcessing() {
        //Stop/Hide spinner
        spinner.stopAnimating()
        nextButton.enabled()
        
        //Re-populate Log In text
        nextButton.setTitle(NSLocalizedString("NEXT", comment: "Log In"), forState: .Normal)
    }
    
    func clearView() {
        //Clear view on Log In
        emailInput.text = ""
        nextButton.disabled()
    }
    
    
    //MARK:- PREPARE FOR SEGUE
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let signUpVC = segue.destinationViewController as! SignUpViewController
        signUpVC.emailAddress = email
    }
    
    
    //MARK:- DISMISS
    @IBAction func dismissVC() {
        dismissKeyboard()
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        //Remove keyboard notification observers
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillChangeFrameNotification, object: nil)
        
    }

}
