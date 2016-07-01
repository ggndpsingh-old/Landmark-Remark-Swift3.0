//
//  LoginViewController.swift
//  LandmarkRemark
//
//  Created by Gagandeep Singh on 21/6/16.
//  Copyright © 2016 Gagandeep Singh. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController, LoginViewModelDelegate {
    
    //MARK:- OUTLETS

    @IBOutlet weak var usernameInput: TranslucentTextField!
    @IBOutlet weak var passwordInput: TranslucentTextField!
    @IBOutlet weak var loginButton: LargeWhiteButton!
    
    @IBOutlet weak var noAccountLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginSpinner: UIActivityIndicatorView!
    
    //MARK:- VARIABLES
    
    var viewModel: LoginViewModel!
    
    var tap: UITapGestureRecognizer!
    
    //------------------------------------------------------------------------------------------------
    // MARK: - View controller life cycle methods
    //------------------------------------------------------------------------------------------------
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        //initialize View Model
        viewModel = LoginViewModel(delegate: self)
        
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //Set Self as Active View Controller
        ActiveViewController = self
        
        //Add keyboard notification observer
        NotificationCenter.default().addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default().addObserver(self, selector: #selector(self.keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        usernameInput.addTarget(self, action: #selector(textFieldDidChange(textField: )), for: UIControlEvents.editingChanged)
        passwordInput.addTarget(self, action: #selector(textFieldDidChange(textField: )), for: UIControlEvents.editingChanged)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        clearView()
        
        //Remove keyboard notification observers
        NotificationCenter.default().removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default().removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
    }
    
    
    
    
    //------------------------------------------------------------------------------------------------
    // MARK: - View controller styling methods
    //------------------------------------------------------------------------------------------------
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    func setViewBackground() {
        self.view.layer.insertSublayer(purpleGradient(), at: 0)
    }
    
    
    func populizeStrings() {
        //Populize localised Strings
        loginButton.setTitle(NSLocalizedString("LOG_IN", comment: "Log In"), for: UIControlState.application)
        noAccountLabel.text = NSLocalizedString("NO_ACCOUNT_QUESTION", comment: "No Account")
        signUpButton.setTitle(NSLocalizedString("SIGN_UP", comment: "Sign Up"), for: UIControlState.application)
        usernameInput.placeholder = NSLocalizedString("USERNAME", comment: "Username")
        passwordInput.placeholder = NSLocalizedString("PASSWORD", comment: "Password")
    }
    
    
    
    
    // -------------------------------
    // MARK :- user Actions on the UI
    // -------------------------------
    @IBAction func login(sender: LargeWhiteButton) {
        
        viewModel.username = usernameInput.text!
        viewModel.password = passwordInput.text!
        
        viewModel.login()
    }
    
    
    
    
    // -------------------------------------------------------------------------------------------------------
    // MARK :- LoginViewModelDelegate method implementation, called by the view-model to notify anything
    // -------------------------------------------------------------------------------------------------------
    
    func loginSuccessful(withUser user: PFUser) {
        CurrentUser = UserObject(withParseUser: user)
        RootVC.pushViewController(MainTBC, animated: true)

    }
    
    func invalidUsername() {
        usernameInput.invalid()
        usernameInput.becomeFirstResponder()
    }
    
    func invalidPassword() {
        passwordInput.invalid()
        passwordInput.becomeFirstResponder()
    }
    
    func showProcessing() {
        dismissKeyboard()
        
        //Show spinner on top of login button
        loginSpinner.startAnimating()
        loginButton.disabled()
        
        //Hides Log In text and leaves the border intact for a better look
        loginButton.setTitle("", for: UIControlState.application)
    }
    
    func hideProcessing() {
        //Stop/Hide spinner
        loginSpinner.stopAnimating()
        loginButton.enabled()
        
        //Re-populate Log In text
        loginButton.setTitle(NSLocalizedString("LOG_IN", comment: "Log In"), for: UIControlState.application)
    }
    
    // ------------------------------------
    // MARK :- Helper methods
    // ------------------------------------
    
    
    func clearView() {
        //Clear view on Log In
        dismissKeyboard()
        usernameInput.text = ""
        passwordInput.text = ""
        loginButton.disabled()
    }
}

    


// ------------------------------------
// MARK :- UITextFieldDelegate Extension
// ------------------------------------
extension LoginViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        view.addGestureRecognizer(tap)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        view.removeGestureRecognizer(tap)
    }
    
    func textFieldDidChange(textField: UITextField) {
        
        //If either of the inputs is emply, disable Login Button
        if usernameInput.text == "" || passwordInput.text == "" {
            loginButton.disabled()
            
        } else {
            loginButton.enabled()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case usernameInput:
            passwordInput.becomeFirstResponder()
            
        default:
            login(sender: loginButton)
        }
        return true
    }
    
    
    
    
    //MARK:- KEYBOARD NOTIFICATIONS
    func keyboardWillChange(notification: NSNotification) {
        if let keyboardRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue() {
            
            let keyboardOrigin = keyboardRect.origin.y
            let buttonMaxY = loginButton.frame.maxY
            
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
}
