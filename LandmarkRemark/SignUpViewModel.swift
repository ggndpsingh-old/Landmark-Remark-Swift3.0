//
//  SignUpViewModel.swift
//  LandmarkRemark
//
//  Created by Gagandeep Singh on 30/6/16.
//  Copyright © 2016 Gagandeep Singh. All rights reserved.
//

import Foundation


// The protocol for SignupViewModel delegate, implemented by the Signup View Controller
public protocol SignUpViewModelDelegate: class {
    
    func signupSuccessful()
    
    func invalidUsername()
    func validUsername()
    
    func invalidPassword()
    
    func showUsernameProcessing()
    func hideUsernameProcessing()
    
    func showProcessing()
    func hideProcessing()
    
}


// The View Model for Signup View Controller
public class SignUpViewModel {
    
    // public properties of the view-model exposed to its view-controller
    
    var validUsername = Validity.Invalid
    var validPassword = Validity.Invalid
    
    public var email: String = ""
    public var username: String = ""
    public var password: String = ""
    
    // The delgate of the view-model to call back / pass back information to the view-controller
    public weak var delegate: SignUpViewModelDelegate?
    
    // reference to the Authentication service
    private let authenticationService: UserAuthenticationService
    
    // initializer
    public init(delegate: SignUpViewModelDelegate) {
        self.delegate = delegate
        authenticationService = UserAuthenticationService()
    }
    
    func validateUsername() {
        //Username should meet set criteria
        if username.characters.count >= MIN_USERNAME_LENGTH {
            
            //Check username availability
            delegate?.showUsernameProcessing()
            
            authenticationService.checkAvailabilityInUserClass(inField: "username", forValue: username, completion: { (available) in
                
                if available {
                    //Username available
                    self.delegate?.validUsername()
                    self.validUsername = .Valid
                    
                } else {
                    //Username unavailable
                    showMessageView(message: "'\(self.username)' \(NSLocalizedString("IS_NOT_AVAILABLE", comment: "is not available")).", valid: false, completion: nil)
                    self.delegate?.invalidUsername()
                    self.validUsername = .Invalid
                }
                
                self.delegate?.hideUsernameProcessing()
            })
            
        } else {
            //Username is too short
            showMessageView(message: NSLocalizedString("USERNAME_TOO_SHORT", comment: "Username too short."), valid: false, completion: nil)
            
            self.delegate?.invalidUsername()
            self.validUsername = .Invalid
        }
    }
    
    
    func signUp() {
        
        //Run a final validation before sign up
        if validUsername == .Invalid {
            //Username is Invalid
            showMessageView(message: NSLocalizedString("ENTER_VALID_USERNAME", comment: "Enter valid username"), valid: false, completion: { (success) in
                self.delegate?.invalidUsername()
            })
            
        } else if validPassword == .Invalid {
            //Password is Invalid
            showMessageView(message: NSLocalizedString("PASSWORD_TOO_SHORT", comment: "Password Too Short"), valid: false, completion: { (success) in
                self.delegate?.invalidPassword()
            })
            
        } else {
            //Process Sign Up
            self.delegate?.showProcessing()
            
            //Create a new user object for current user
            CurrentUser = UserObject()
            
            //Set user credentials
            CurrentUser!.email    = self.email
            CurrentUser!.username = self.username
            CurrentUser!.password = self.password
            
            //Sign Up user
            CurrentUser!.signUpAsNewUser { (success) in
                if success {
                    //Sign up successfull
                    self.delegate?.signupSuccessful()
                    
                    //Add user to current installation
                    self.authenticationService.updateParseInstallation()
                    
                } else {
                    //Sign up failed
                    showMessageView(message: NSLocalizedString("FAILED_SIGNUP", comment: "Failed Signup"), valid: false, completion: nil)
                }
                
                self.delegate?.hideProcessing()
            }
        }
    }
    
    
}
