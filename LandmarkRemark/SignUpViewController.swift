//
//  SignUpViewController.swift
//  LandmarkRemark
//
//  Created by Gagandeep Singh on 21/6/16.
//  Copyright © 2016 Gagandeep Singh. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    //MARK:- OUTLETS
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var signUpButton: LargeWhiteButton!
    @IBOutlet weak var usernameSpinner: UIActivityIndicatorView!
    
    @IBOutlet weak var emailInput: TranslucentTextField!
    @IBOutlet weak var passwordInput: TranslucentTextField!
    @IBOutlet weak var usernameInput: TranslucentTextField!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var signupSpinner: UIActivityIndicatorView!
    
    
    //MARK:- VARIABLES
    var emailAddress: String!
    var password: String!
    var username: String!
    var validUsername = Validity.Invalid
    var validPassword = Validity.Invalid
    var tap: UITapGestureRecognizer!
    
    
    //MARK:- METHODS
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailInput.textColor = UIColor.whiteColor().colorWithAlphaComponent(0.75)
        
        //Start with sign up button disabled
        signUpButton.disabled()

        //Set Delegates
        usernameInput.delegate = self
        passwordInput.delegate = self
        
        //Validate inputs as editing changes
        self.usernameInput.addTarget(self, action: #selector(self.textFieldDidChange), forControlEvents: UIControlEvents.EditingChanged)
        self.passwordInput.addTarget(self, action: #selector(self.textFieldDidChange), forControlEvents: UIControlEvents.EditingChanged)
        
        
        //Tap to dismiss keyboard
        self.tap = UITapGestureRecognizer()
        self.tap.addTarget(self, action: #selector(dismissKeyboard))
        
        //Prepare view
        setViewBackground()
        populizeStrings()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //Add keyboard notification observers
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillChange(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        //Populise email input
        emailInput.text = emailAddress
        
        //Email cannot be changed on this view
        emailInput.enabled = false
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.usernameInput.becomeFirstResponder()
    }
    
    
    //MARK:- PREPARE VIEW
    func setViewBackground() {
        self.view.layer.insertSublayer(purpleGradient(), atIndex: 0)
    }
    
    func populizeStrings() {
        self.titleLabel.text = NSLocalizedString("ACCOUNT_DETAILS", comment: "Account Details")
        self.emailInput.placeholder = NSLocalizedString("EMAIL_ADDRESS", comment: "Email Address")
        self.passwordInput.placeholder = NSLocalizedString("SELECT_PASSWORD", comment: "Select Password")
        self.usernameInput.placeholder = NSLocalizedString("SELECT_USERNAME", comment: "Select Username")
        self.signUpButton.setTitle(NSLocalizedString("SIGN_UP", comment: "Sign Up"), forState: .Normal)
    }
    
    
    //MARK:- TEXT FIELD DELEGATE
    func textFieldDidChange(textField: UITextField) {
        
        //If either input is empty, disable sign up button
        if usernameInput.text == "" || passwordInput.text == "" {
            signUpButton.disabled()
        } else {
            signUpButton.enabled()
        }
        
        switch textField {
        case usernameInput:
            username = textField.text!
        
        default:
            let password = passwordInput.text!
            if password.characters.count >= MIN_PASSWORD_LENGTH {
                self.password = password
                validPassword = .Valid
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case usernameInput:
            self.passwordInput.becomeFirstResponder()
        
        default:
            signUp(signUpButton)
            break;
        }
        
        return true
    }
    
    func validateUsername() {
        //Username should meet set criteria
        if username.characters.count >= MIN_USERNAME_LENGTH {
            
            //Check username availability
            usernameSpinner.startAnimating()
            
            checkAvailabilityInUserClass(inField: "username", forValue: username, completion: { (available) in
                
                if available {
                    //Username available
                    self.usernameInput.valid()
                    self.validUsername = .Valid
                    
                } else {
                    //Username unavailable
                    showMessageView("'\(self.username)' \(NSLocalizedString("IS_NOT_AVAILABLE", comment: "is not available")).", valid: false, completion: nil)
                    self.usernameInput.invalid()
                    self.validUsername = .Invalid
                }
                
                self.usernameSpinner.stopAnimating()
            })
        
        } else {
            //Username is too short
            showMessageView(NSLocalizedString("USERNAME_TOO_SHORT", comment: "Username too short."), valid: false, completion: nil)
            usernameInput.invalid()
            validUsername = .Invalid
        }
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        if textField == usernameInput && textField.text?.characters.count > 0 {
            validateUsername()
        }
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        view.addGestureRecognizer(tap)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        view.removeGestureRecognizer(tap)
    }
    
    
    @IBAction func signUp(sender: UIButton) {
        
        //Run a final validation before sign up
        if validUsername == .Invalid {
            //Username is Invalid
            showMessageView(NSLocalizedString("ENTER_VALID_USERNAME", comment: "Enter valid username"), valid: false, completion: { (success) in
                self.usernameInput.becomeFirstResponder()
            })
            
        } else if validPassword == .Invalid {
            //Password is Invalid
            showMessageView(NSLocalizedString("PASSWORD_TOO_SHORT", comment: "Password Too Short"), valid: false, completion: { (success) in
                self.passwordInput.becomeFirstResponder()
            })
            
        } else {
            //Process Sign Up
            dismissKeyboard()
            showProcessing()
            
            //Create a new user object for current user
            CurrentUser = UserObject()
            
            //Set user credentials
            CurrentUser!.email = self.emailInput.text!
            CurrentUser!.username = self.usernameInput.text!
            CurrentUser!.password = self.passwordInput.text!
            
            //Sign Up user
            CurrentUser!.signUpAsNewUser { (success) in
                if success {
                    //Sign up successfull
                    showMessageView(NSLocalizedString("SUCCESSFUL_SIGNUP", comment: "Successful Signup"), valid: true, completion: nil)
                    
                    //Add user to current installation
                    updateParseInstallation()
                    
                    //Go To Home View
                    RootVC.pushViewController(MainTBC, animated: true)
                    
                } else {
                    //Sign up failed
                    showMessageView(NSLocalizedString("FAILED_SIGNUP", comment: "Failed Signup"), valid: false, completion: nil)
                }
                
                self.hideProcessing()
            }
        }
    }
    
    //MARK:- LOGIN PROCESSING STATES
    func showProcessing() {
        
        //Cannot dismiss view controller when processing
        self.closeButton.hidden = true
        
        //Show spinner on top of login button
        signupSpinner.startAnimating()
        
        //Hides Log In text and leaves the border intact for a better look
        signUpButton.setTitle("", forState: .Normal)
        signUpButton.disabled()
    }
    
    func hideProcessing() {
        dismissKeyboard()
        
        //Stop/Hide spinner
        signupSpinner.stopAnimating()
        
        self.closeButton.hidden = false
        
        //Re-populate Sign Up text
        signUpButton.enabled()
        signUpButton.setTitle(NSLocalizedString("SIGN_UP", comment: "Log In"), forState: .Normal)
    }
    
    func clearView() {
        //Clear view on Log In
        usernameInput.text = ""
        passwordInput.text = ""
        signUpButton.disabled()
        closeButton.hidden = false
    }
    
    //MARK:- KEYBOARD NOTIFICATIONS
    func keyboardWillChange(notification: NSNotification) {
        if let keyboardRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            
            let keyboardOrigin = keyboardRect.origin.y
            let buttonMaxY = CGRectGetMaxY(signUpButton.frame)
            
            // If keyboard overlaps the button
            if keyboardOrigin < buttonMaxY {
                //Move view up
                view.frame.origin.y = 0 - (buttonMaxY - keyboardOrigin) - MIN_KEYBOARD_DISTANCE
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func dismissVC() {
        dismissKeyboard()
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        clearView()
        
        //Remove keyboard notification observers
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillChangeFrameNotification, object: nil)
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
