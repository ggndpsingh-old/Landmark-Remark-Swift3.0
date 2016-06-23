//
//  Singletons.swift
//  LandmarkRemark
//
//  Created by Gagandeep Singh on 21/6/16.
//  Copyright © 2016 Gagandeep Singh. All rights reserved.
//

import Foundation
import UIKit

var CurrentUser: UserObject?

let appDelegate  = UIApplication.sharedApplication().delegate as! AppDelegate
let RootVC : UINavigationController = appDelegate.window!.rootViewController as! UINavigationController
let MainStoryboard = UIStoryboard(name: "Main", bundle: nil)
let HomeVC  = MainStoryboard.instantiateViewControllerWithIdentifier("HomeViewController")
let MainTBC = MainStoryboard.instantiateViewControllerWithIdentifier("MainTabBarController")


//MARK:- Screen Specs
let ScreenSize = UIScreen.mainScreen().bounds.size
let ScreenScale = UIScreen.mainScreen().scale