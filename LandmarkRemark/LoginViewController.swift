//
//  LoginViewController.swift
//  LandmarkRemark
//
//  Created by Gagandeep Singh on 21/6/16.
//  Copyright © 2016 Gagandeep Singh. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    //MARK:- OUTLETS

    @IBOutlet weak var usernameInput: TranslucentTextField!
    @IBOutlet weak var passwordInput: TranslucentTextField!
    @IBOutlet weak var loginButton: LargeWhiteButton!
    
    @IBOutlet weak var noAccountLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginSpinner: UIActivityIndicatorView!
    
    //MARK:- VARIABLES
    var tap: UITapGestureRecognizer!
    
    //MARK:- METHODS
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        
        //Start with Log In button disabled
        loginButton.disabled()
        
        //Set input delegates
        usernameInput.delegate = self
        passwordInput.delegate = self
        
        //Tap to dismiss keyboard
        self.tap = UITapGestureRecognizer()
        self.tap.addTarget(self, action: #selector(dismissKeyboard))

        setViewBackground()
        populizeStrings()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        //Add keyboard notification observer
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillChange(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        usernameInput.addTarget(self, action: #selector(textFieldDidChange(_:)), forControlEvents: .EditingChanged)
        passwordInput.addTarget(self, action: #selector(textFieldDidChange(_:)), forControlEvents: .EditingChanged)
    }
    
    func setViewBackground() {
        self.view.layer.insertSublayer(purpleGradient(), atIndex: 0)
    }
    
    func populizeStrings() {
        //Populize localised Strings
        loginButton.setTitle(NSLocalizedString("LOG_IN", comment: "Log In"), forState: .Normal)
        noAccountLabel.text = NSLocalizedString("NO_ACCOUNT_QUESTION", comment: "No Account")
        signUpButton.setTitle(NSLocalizedString("SIGN_UP", comment: "Sign Up"), forState: .Normal)
        usernameInput.placeholder = NSLocalizedString("USERNAME", comment: "Username")
        passwordInput.placeholder = NSLocalizedString("PASSWORD", comment: "Password")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func login(sender: LargeWhiteButton) {
        
        let username = usernameInput.text!
        let password = passwordInput.text!
        
        if username.characters.count < MIN_USERNAME_LENGTH {
            showMessageView(NSLocalizedString("ENTER_VALID_USERNAME", comment: "Enter valid username"), valid: false, completion: nil)
            usernameInput.invalid()
            usernameInput.becomeFirstResponder()
        
        } else if password.characters.count < MIN_PASSWORD_LENGTH {
            showMessageView(NSLocalizedString("ENTER_VALID_PASSWORD", comment: "Enter valid password"), valid: false, completion: nil)
            passwordInput.invalid()
            passwordInput.becomeFirstResponder()
        
        } else {
            
            //Check if username exists
            showProcessing()
            checkAvailabilityInUserClass(inField: "username", forValue: username, completion: { (available) in
                if available {
                    //Username does not exist
                    showMessageView("\(NSLocalizedString("USERNAME_DOES_NOT_EXIST", comment: "Username doesn't exist")) '\(username)'", valid: false, completion: nil)
                    self.hideProcessing()
                
                } else {
                    //Username exists, continue login
                    self.performLogin(withUsername: username, password: password)
                }
            })
        }
    }
    
    func performLogin(withUsername username: String, password: String) {
        
        PFUser.logInWithUsernameInBackground(username, password: password, block: { (user, error) -> Void in
            
            if let user = user {
                CurrentUser = UserObject(withParseUser: user)
                RootVC.pushViewController(MainTBC, animated: true)
                updateParseInstallation()
                
            } else {
                if error?.code == 101 {
                    //Incorrect Password
                    showMessageView("\(NSLocalizedString("INCORRECT_PASSWORD_FOR", comment: "Incorrect password for")) '\(username)'", valid: false, completion: nil)
                    
                } else {
                    showMessageView(NSLocalizedString("FAILED_LOGIN", comment: "Login failed"), valid: false, completion: nil)
                }
            }
            self.hideProcessing()
        })
    }
    
    //MARK:- LOGIN PROCESSING STATES
    func showProcessing() {
        dismissKeyboard()
        
        //Show spinner on top of login button
        loginSpinner.startAnimating()
        loginButton.disabled()
        
        //Hides Log In text and leaves the border intact for a better look
        loginButton.setTitle("", forState: .Normal)
    }
    
    func hideProcessing() {
        //Stop/Hide spinner
        loginSpinner.stopAnimating()
        loginButton.enabled()
        
        //Re-populate Log In text
        loginButton.setTitle(NSLocalizedString("LOG_IN", comment: "Log In"), forState: .Normal)
    }
    
    func clearView() {
        //Clear view on Log In
        usernameInput.text = ""
        passwordInput.text = ""
        loginButton.disabled()
    }
    
    //MARK:- TEXT FIELD DELEGATE
    func textFieldDidBeginEditing(textField: UITextField) {
        view.addGestureRecognizer(tap)
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        view.removeGestureRecognizer(tap)
    }
    
    func textFieldDidChange(notification: NSNotification) {
        
        //If either of the inputs is emply, disable Login Button
        if usernameInput.text == "" || passwordInput.text == "" {
            loginButton.disabled()
        
        } else {
            loginButton.enabled()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case usernameInput:
            passwordInput.becomeFirstResponder()
            
        default:
            login(loginButton)
        }
        return true
    }
    
    //MARK:- KEYBOARD NOTIFICATIONS
    func keyboardWillChange(notification: NSNotification) {
        if let keyboardRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            
            let keyboardOrigin = keyboardRect.origin.y
            let buttonMaxY = CGRectGetMaxY(loginButton.frame)
            
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
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        clearView()
        
        //Remove keyboard notification observers
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillChangeFrameNotification, object: nil)
        
    }
}
