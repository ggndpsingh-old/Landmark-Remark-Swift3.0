//
//  Constants.swift
//  LandmarkRemark
//
//  Created by Gagandeep Singh on 21/6/16.
//  Copyright © 2016 Gagandeep Singh. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

let MIN_USERNAME_LENGTH: Int = 6
let MIN_PASSWORD_LENGTH: Int = 8
let MIN_KEYBOARD_DISTANCE: CGFloat = 10
let MESSAGE_DELAY: NSTimeInterval = 2.5

let MAX_NOTE_LENGTH = 200

let TIGERSPIKE_LOCATION = CLLocation(latitude: -37.8139176, longitude: 144.9739824)

enum Validity {
    case Valid
    case Invalid
}