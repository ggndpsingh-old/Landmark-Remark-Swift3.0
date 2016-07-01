//
//  CustomViews.swift
//  LandmarkRemark
//
//  Created by Gagandeep Singh on 21/6/16.
//  Copyright © 2016 Gagandeep Singh. All rights reserved.
//

import Foundation
import UIKit

//View for Error & Success Messages
func showMessageView(message: String, valid: Bool, completion: ((success: Bool) -> Void)? ) {
    
    //Use UIWindow to present it above the Status Bar
    var window: UIWindow? = UIWindow(frame: CGRect(x: 0, y: 0, width: ScreenSize.width, height: 20))
    window!.windowLevel = UIWindowLevelStatusBar + 1
    
    //Message Label
    let label = UILabel(frame: CGRect(x: 0, y: -20, width: ScreenSize.width, height: 20))
    label.backgroundColor = valid ? UIColor.validGreen() : UIColor.errorRed()
    label.textColor = UIColor.white()
    label.font = UIFont.boldSystemFont(ofSize: 11)
    label.textAlignment = NSTextAlignment.center
    label.numberOfLines = 0
    label.text = message
    
    window!.addSubview(label)
    window!.makeKeyAndVisible()
    
    //Show Message
    UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: {
        label.frame.origin.y = 0
        label.alpha = 1
        }, completion: nil)
    
    //Hide Message after desired time
    UIView.animate(withDuration: 0.2, delay: MESSAGE_DELAY, options: UIViewAnimationOptions.curveEaseIn, animations: {
        label.frame.origin.y = -20
        label.alpha = 0
    }) { (success) -> Void in
        
        window = nil
        completion?(success: true)
    }
}
