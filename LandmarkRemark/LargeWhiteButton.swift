//
//  LargeWhiteButton.swift
//  LandmarkRemark
//
//  Created by Gagandeep Singh on 21/6/16.
//  Copyright © 2016 Gagandeep Singh. All rights reserved.
//

import UIKit

class LargeWhiteButton: UIButton {
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.white().withAlphaComponent(0.5).cgColor
    }
    
    func disabled() {
        isEnabled = false
        alpha = 0.5
    }
    
    func enabled() {
        isEnabled = true
        alpha = 1
    }

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
