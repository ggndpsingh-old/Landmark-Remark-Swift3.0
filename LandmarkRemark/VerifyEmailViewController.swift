//
//  VerifyEmailViewController.swift
//  LandmarkRemark
//
//  Created by Gagandeep Singh on 21/6/16.
//  Copyright © 2016 Gagandeep Singh. All rights reserved.
//

import UIKit

class VerifyEmailViewController: UIViewController, VerifyEmailViewModelDelegate {
    
    //MARK:- OUTLETS
    @IBOutlet weak var signUpTitle: UILabel!
    @IBOutlet weak var emailInput: TranslucentTextField!
    @IBOutlet weak var nextButton: LargeWhiteButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    //MARK:- VARIABLES
    
    var viewModel: VerifyEmailViewModel!
    
    var email: String!
    var tap: UITapGestureRecognizer!
    
    
    
    
    //------------------------------------------------------------------------------------------------
    // MARK: - View controller life cycle methods
    //------------------------------------------------------------------------------------------------
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = VerifyEmailViewModel(delegate: self)
        
        //Start with Next Button disabled
        nextButton.disabled()
        
        //Tap to dismiss keyboard
        self.tap = UITapGestureRecognizer()
        self.tap.addTarget(self, action: #selector(dismissKeyboard))
        
        //Prepare View
        setViewBackground()
        populizeStrings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Set Self as Active View Controller
        ActiveViewController = self
        
        self.emailInput.delegate = self
        
        //Add Keyboard Notification Observers
        NotificationCenter.default().addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default().addObserver(self, selector: #selector(self.keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        emailInput.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.emailInput.becomeFirstResponder()
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
        //Set the gradient for background
        self.view.layer.insertSublayer(purpleGradient(), at: 0)
    }
    
    func populizeStrings() {
        self.signUpTitle.text = NSLocalizedString("SIGN_UP", comment: "Sign Up")
        self.emailInput.placeholder = NSLocalizedString("EMAIL_ADDRESS", comment: "Email Address")
        self.nextButton.setTitle(NSLocalizedString("NEXT", comment: "Next"), for: UIControlState.application)
    }
    
    
    
    // -------------------------------
    // MARK :- user Actions on the UI
    // -------------------------------
    @IBAction func verifyEmail(sender: UIButton) {
        
        viewModel.email = self.emailInput.text!
        viewModel.verifyEmail()
        
    }
    
    //Dismiss View Controller
    @IBAction func dismissVC() {
        dismissKeyboard()
        let _ = navigationController?.popViewController(animated: true)
    }
    
    
    
    
    // -------------------------------
    // MARK :- Segue Methods
    // -------------------------------
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        let signUpVC = segue.destinationViewController as! SignUpViewController
        signUpVC.emailAddress = email
    }
    
    
    
    
    // -------------------------------------------------------------------------------------------------------
    // MARK :- VerifyEmailViewModelDelegate method implementation, called by the view-model to notify anything
    // -------------------------------------------------------------------------------------------------------
    func continueSignup(withEmail email: String) {
        
        self.email = email
        self.performSegue(withIdentifier: "goToSignUp", sender: self)
    }
    
    func invalidEmail() {
        emailInput.invalid()
        emailInput.becomeFirstResponder()
    }
    
    func showProcessing() {
        dismissKeyboard()
        
        //Show spinner on top of login button
        spinner.startAnimating()
        nextButton.disabled()
        
        //Hides Log In text and leaves the border intact for a better look
        nextButton.setTitle("", for: UIControlState.application)
    }
    
    func hideProcessing() {
        //Stop/Hide spinner
        spinner.stopAnimating()
        nextButton.enabled()
        
        //Re-populate Log In text
        nextButton.setTitle(NSLocalizedString("NEXT", comment: "Log In"), for: UIControlState.application)
    }
    
    
    
    
    // ------------------------------------
    // MARK :- Helper methods
    // ------------------------------------
    
    func clearView() {
        //Clear view on Log In
        view.endEditing(true)
        emailInput.text = ""
        nextButton.disabled()
    }
}





// ------------------------------------
// MARK :- UITextFieldDelegate methods
// ------------------------------------

extension VerifyEmailViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        view.addGestureRecognizer(tap)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        view.removeGestureRecognizer(tap)
    }
    
    func textFieldDidChange(textField: UITextField) {
        textField.text == "" ? nextButton.disabled() : nextButton.enabled()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.verifyEmail(sender: nextButton)
        view.endEditing(true)
        return true
    }
    
    
    //MARK:  KEYBOARD NOTIFICATIONS
    func keyboardWillChange(notification: NSNotification) {
        if let keyboardRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue() {
            
            let keyboardOrigin = keyboardRect.origin.y
            let buttonMaxY = nextButton.frame.maxY
            
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
}
