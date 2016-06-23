//
//  TranslucentTextField.swift
//  LandmarkRemark
//
//  Created by Gagandeep Singh on 21/6/16.
//  Copyright © 2016 Gagandeep Singh. All rights reserved.
//

import UIKit

class TranslucentTextField: UITextField {
    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10);
    
    override func awakeFromNib() {
        //Set Colors
        self.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder!, attributes: [NSForegroundColorAttributeName: UIColor.whiteColor().colorWithAlphaComponent(0.5)])
        
        //Set Corner Radius
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRectForBounds(bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    func invalid() {
        self.layer.borderColor = UIColor.errorRed().colorWithAlphaComponent(0.75).CGColor
        self.layer.borderWidth = 1
    }
    
    func valid() {
        self.layer.borderWidth = 0
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
