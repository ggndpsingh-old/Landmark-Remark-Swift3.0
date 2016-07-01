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

//MARK:- Extentions
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



//Background Gradient
func purpleGradient() -> CAGradientLayer {
    let purpleGradient: CAGradientLayer = CAGradientLayer()
    purpleGradient.colors = [UIColor.gradientPurpleOne().cgColor, UIColor.gradientPurpleTwo().cgColor]
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
            return self.substring(to: self.index(self.startIndex, offsetBy: length)) + ("...")
        } else {
            return self
        }
    }
    
    /**
     To trim while spaces from left and right of a string
     */
    func trim() -> String
    {
        return self.trimmingCharacters(in: NSCharacterSet.whitespaces())
    }
    
    /**
     To condense while spaces wihtin the string
     */
    func condenseWhitespace() -> String {
        let components = self.components(separatedBy: NSCharacterSet.whitespaces())
        let filtered = components.filter({!$0.isEmpty})
        return filtered.joined(separator: " ")
    }
    
}

//MARK:- NSDate
extension NSDate {
    func longFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM, YYYY hh:mm a"
        return dateFormatter.string(from: self as Date)
    }
    
    func dateOnlyFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM, YYYY"
        return dateFormatter.string(from: self as Date)
    }
}



/* --- Custom Classes --- */
/*
    Create a custom class for MKPointAnnotation with a NoteObject variable.
    This is used to get details of a note when an annotation is tapped on.
*/

public class NoteAnnotation: MKPointAnnotation {
    var note: NoteObject!
}


/*
 Create a custom class for UIButton with an IndexPath variable.
 This is used to get the IndexPath of the cell in which the button is tapped.
 */

class IndexPathButton: UIButton {
    var indexPath: NSIndexPath!
}


