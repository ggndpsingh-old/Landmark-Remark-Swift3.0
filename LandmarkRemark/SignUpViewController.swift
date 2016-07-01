//
//  SignUpViewController.swift
//  LandmarkRemark
//
//  Created by Gagandeep Singh on 21/6/16.
//  Copyright © 2016 Gagandeep Singh. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController, SignUpViewModelDelegate {
    
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
    var tap: UITapGestureRecognizer!
    
    var viewModel: SignUpViewModel!
    
    
    //------------------------------------------------------------------------------------------------
    // MARK: - View controller life cycle methods
    //------------------------------------------------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = SignUpViewModel(delegate: self)
        
        self.emailInput.textColor = UIColor.white().withAlphaComponent(0.75)
        
        //Start with sign up button disabled
        signUpButton.disabled()

        //Set Delegates
        usernameInput.delegate = self
        passwordInput.delegate = self
        
        //Validate inputs as editing changes
        usernameInput.addTarget(self, action: #selector(textFieldDidChange(textField: )), for: UIControlEvents.editingChanged)
        passwordInput.addTarget(self, action: #selector(textFieldDidChange(textField: )), for: UIControlEvents.editingChanged)
        
        
        //Tap to dismiss keyboard
        self.tap = UITapGestureRecognizer()
        self.tap.addTarget(self, action: #selector(dismissKeyboard))
        
        //Prepare view
        setViewBackground()
        populizeStrings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Set Self as Active View Controller
        ActiveViewController = self
        
        //Add keyboard notification observers
        NotificationCenter.default().addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default().addObserver(self, selector: #selector(self.keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        //Populise email input
        emailInput.text = emailAddress
        
        //Email cannot be changed on this view
        emailInput.isEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.usernameInput.becomeFirstResponder()
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
        self.titleLabel.text = NSLocalizedString("ACCOUNT_DETAILS", comment: "Account Details")
        self.emailInput.placeholder = NSLocalizedString("EMAIL_ADDRESS", comment: "Email Address")
        self.passwordInput.placeholder = NSLocalizedString("SELECT_PASSWORD", comment: "Select Password")
        self.usernameInput.placeholder = NSLocalizedString("SELECT_USERNAME", comment: "Select Username")
        self.signUpButton.setTitle(NSLocalizedString("SIGN_UP", comment: "Sign Up"), for: UIControlState.application)
    }
    
    
    
    
    
    // -------------------------------
    // MARK :- user Actions on the UI
    // -------------------------------
    
    @IBAction func signUp(sender: LargeWhiteButton) {
        self.viewModel.email    = emailInput.text!
        self.viewModel.username = usernameInput.text!
        self.viewModel.password = passwordInput.text!
        self.viewModel.signUp()
    }
    
    @IBAction func dismissVC() {
        dismissKeyboard()
        let _ = navigationController?.popViewController(animated: true)
    }
    
    
    
    // -------------------------------------------------------------------------------------------------------
    // MARK :- SigUpViewModelDelegate method implementation, called by the view-model to notify anything
    // -------------------------------------------------------------------------------------------------------
    
    func signupSuccessful() {
        //Go To Home View
        RootVC.pushViewController(MainTBC, animated: true)
    }
    
    func invalidUsername() {
        usernameInput.invalid()
        usernameInput.becomeFirstResponder()
    }
    
    func validUsername() {
        usernameInput.valid()
    }
    
    func invalidPassword() {
        passwordInput.invalid()
        passwordInput.becomeFirstResponder()
    }
    
    func showUsernameProcessing() {
        usernameSpinner.startAnimating()
    }
    
    func hideUsernameProcessing() {
        usernameSpinner.stopAnimating()
    }
    
    func showProcessing() {
        
        //Cannot dismiss view controller when processing
        self.closeButton.isHidden = true
        
        //Show spinner on top of login button
        signupSpinner.startAnimating()
        
        //Hides Log In text and leaves the border intact for a better look
        signUpButton.setTitle("", for: UIControlState.application)
        signUpButton.disabled()
    }
    
    func hideProcessing() {
        dismissKeyboard()
        
        //Stop/Hide spinner
        signupSpinner.stopAnimating()
        
        self.closeButton.isHidden = false
        
        //Re-populate Sign Up text
        signUpButton.enabled()
        signUpButton.setTitle(NSLocalizedString("SIGN_UP", comment: "Log In"), for: UIControlState.application)
    }
    
    
    
    
    
    
    // ------------------------------------
    // MARK :- Helper methods
    // ------------------------------------
    func clearView() {
        //Clear view on Log In
        usernameInput.text = ""
        passwordInput.text = ""
        signUpButton.disabled()
        closeButton.isHidden = false
    }
}


// ------------------------------------
// MARK :- UITextFieldDelegate methods
// ------------------------------------

extension SignUpViewController: UITextFieldDelegate {
    
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
                self.viewModel.validPassword = .Valid
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case usernameInput:
            self.passwordInput.becomeFirstResponder()
            
        default:
            self.signUp(sender: signUpButton)
            break;
        }
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == usernameInput && textField.text?.characters.count > 0 {
            self.viewModel.username = textField.text!
            self.viewModel.validateUsername()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        view.addGestureRecognizer(tap)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        view.removeGestureRecognizer(tap)
    }
    
    
    
    func keyboardWillChange(notification: NSNotification) {
        if let keyboardRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue() {
            
            let keyboardOrigin = keyboardRect.origin.y
            let buttonMaxY = signUpButton.frame.maxY
            
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
