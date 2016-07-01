//
//  VerifyEmailViewModel.swift
//  LandmarkRemark
//
//  Created by Gagandeep Singh on 30/6/16.
//  Copyright © 2016 Gagandeep Singh. All rights reserved.
//

import Foundation

// The protocol for Verify Email View Delegate, implemented by the Verify Email View Controller
public protocol VerifyEmailViewModelDelegate: class {
    
    func invalidEmail()
    func showProcessing()
    func hideProcessing()
    func continueSignup(withEmail: String)
    
}


// The View Model for Verify Email View Controller
public class VerifyEmailViewModel {
    
    // public properties of the view-model exposed to its view-controller
    public var email: String = ""
    
    // The delgate of the view-model to call back / pass back information to the view-controller
    public weak var delegate: VerifyEmailViewModelDelegate?
    
    // reference to the Authentication service
    private let authenticationService: UserAuthenticationService
    
    // initializer
    public init(delegate: VerifyEmailViewModelDelegate) {
        self.delegate = delegate
        authenticationService = UserAuthenticationService()
    }
    
    
    public func verifyEmail() {
        
        if isValidEmail(candidate: email) {
            
            //Valid Email
            self.delegate?.showProcessing()
            
            //Check if email already exists in database
            authenticationService.checkAvailabilityInUserClass(inField: "email", forValue: email, completion: { (available) in
                if available {
                    //Can use email for Sign Up, continue Sign Up
                    self.delegate?.continueSignup(withEmail: self.email)
                    
                } else {
                    //Another account is using the given email
                    showMessageView(message: "\(NSLocalizedString("ANOTHER_ACCOUNT_IS_USING", comment: "Another account is using")) '\(self.email)'", valid: false, completion: { (success) in
                        self.delegate?.invalidEmail()
                    })
                }
                
                self.delegate?.hideProcessing()
            })
            
        } else {
            //Invalid Email
            self.delegate?.invalidEmail()
            showMessageView(message: NSLocalizedString("INVALID_EMAIL", comment: "Invalid Email"), valid: false, completion: nil)
        }
    }
    
}
