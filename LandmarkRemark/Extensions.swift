//
//  Extensions.swift
//  LandmarkRemark
//
//  Created by Gagandeep Singh on 21/6/16.
//  Copyright © 2016 Gagandeep Singh. All rights reserved.
//

import Foundation
import UIKit
import MapKit

//MARK:- Exrentions
extension UIColor {
    class func buttonBlue() -> UIColor {
        return UIColor(red: 42/255,  green: 163/255, blue: 239/255,  alpha: 1)
    }
    
    class func validGreen() -> UIColor {
        return UIColor(red: 50/255,  green: 180/255, blue: 30/255,  alpha: 1)
    }
    
    class func errorRed() -> UIColor {
        return UIColor(red: 210/255, green: 0/255,   blue: 30/255,  alpha: 1)
    }
    
    class func separatorColor() -> UIColor {
        return UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
    }
    
    class func gradientPurpleOne() -> UIColor {
        return UIColor(red: 125/255, green: 66/255, blue: 149/255, alpha: 1)
    }
    
    class func gradientPurpleTwo() -> UIColor {
        return UIColor(red: 94/255, green: 90/255, blue: 185/255, alpha: 1)
    }
}

func purpleGradient() -> CAGradientLayer {
    let purpleGradient: CAGradientLayer = CAGradientLayer()
    purpleGradient.colors = [UIColor.gradientPurpleOne().CGColor, UIColor.gradientPurpleTwo().CGColor]
    purpleGradient.locations = [0.0 , 1.0]
    purpleGradient.startPoint = CGPoint(x: 0.0, y: 0.0)
    purpleGradient.endPoint = CGPoint(x: 1.0, y: 0.0)
    purpleGradient.frame = CGRect(x: 0.0, y: 0.0, width: ScreenSize.width, height: ScreenSize.height)
    return purpleGradient
}


//MARK:- String
extension String {
    func trunc(length: Int) -> String {
        if self.characters.count > length {
            return self.substringToIndex(self.startIndex.advancedBy(length)) + ("...")
        } else {
            return self
        }
    }
}

//MARK:- NSDate
extension NSDate {
    func longFormat() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMMM, YYYY hh:mm a" //format style. Browse online to get a format that fits your needs.
        return dateFormatter.stringFromDate(self)
    }
    
    func dateOnlyFormat() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd MMMM, YYYY" //format style. Browse online to get a format that fits your needs.
        return dateFormatter.stringFromDate(self)
    }
}



/* --- Custom Classes --- */
/*
    Create a custom class for MKPointAnnotation with a NoteObject variable.
    This is used to get details of a note when an annotation is tapped on.
*/

class NoteAnnotation: MKPointAnnotation {
    var note: NoteObject!
}


