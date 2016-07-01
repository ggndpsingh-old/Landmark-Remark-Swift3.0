//
//  LoginViewModel.swift
//  LandmarkRemark
//
//  Created by Gagandeep Singh on 30/6/16.
//  Copyright © 2016 Gagandeep Singh. All rights reserved.
//

import UIKit
import Parse

// The protocol for LoginViewModel delegate, implemented by the Login View Controller
public protocol LoginViewModelDelegate: class {
    
    func invalidUsername()
    func invalidPassword()
    func showProcessing()
    func hideProcessing()
    func loginSuccessful(withUser: PFUser)
    
}

// The View Model for Login View Controller
public class LoginViewModel {
    
    // public properties of the view-model exposed to its view-controller
    public var username: String = ""
    public var  password: String = ""
    
    // The delgate of the view-model to call back / pass back information to the view-controller
    public weak var delegate: LoginViewModelDelegate?
    
    // reference to the Authentication service
    private let authenticationService: UserAuthenticationService
    
    // initializer
    public init(delegate: LoginViewModelDelegate) {
        self.delegate = delegate
        authenticationService = UserAuthenticationService()
    }
    
    
    public func login() {
        
        
        if username.characters.count < MIN_USERNAME_LENGTH {
            showMessageView(message: NSLocalizedString("ENTER_VALID_USERNAME", comment: "Enter valid username"), valid: false, completion: nil)
            delegate?.invalidUsername()
            
        } else if password.characters.count < MIN_PASSWORD_LENGTH {
            showMessageView(message: NSLocalizedString("ENTER_VALID_PASSWORD", comment: "Enter valid password"), valid: false, completion: nil)
            delegate?.invalidPassword()
            
        } else {
            
            // Show loading spinner
            delegate?.showProcessing()
            
            //Perform Login
            self.performLogin(withUsername: username, password: password)
        }
    }
    
    private func performLogin(withUsername username: String, password: String) {
        
        //Check if username exists in the database
        authenticationService.checkAvailabilityInUserClass(inField: "username", forValue: username, completion: { (available) in
            if available {
                //Username does not exist
                showMessageView(message: "\(NSLocalizedString("USERNAME_DOES_NOT_EXIST", comment: "Username doesn't exist")) '\(self.username)'", valid: false, completion: nil)
                self.delegate?.hideProcessing()
                
            } else {
                
                //Username exists, continue login
                self.authenticationService.logInUser(withUsername: username, andPassword: password) { (user, error) in
                    
                    if let user = user {
                        
                        //Tell the view controller to segue to Home Screen
                        self.delegate?.loginSuccessful(withUser: user)
                        
                        //Update Installation object on Parse
                        self.authenticationService.updateParseInstallation()
                        
                    } else {
                        if error?.code == 101 {
                            //Incorrect Password
                            showMessageView(message: "\(NSLocalizedString("INCORRECT_PASSWORD_FOR", comment: "Incorrect password for")) '\(username)'", valid: false, completion: nil)
                            
                        } else {
                            showMessageView(message: NSLocalizedString("FAILED_LOGIN", comment: "Login failed"), valid: false, completion: nil)
                        }
                    }
                    self.delegate?.hideProcessing()
                }
            }
        })
    }
    
}
