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

//Keep track of active view.
var ActiveViewController: AnyObject?

let appDelegate  = UIApplication.shared().delegate as! AppDelegate
let RootVC : UINavigationController = appDelegate.window!.rootViewController as! UINavigationController
let MainStoryboard = UIStoryboard(name: "Main", bundle: nil)
let HomeVC  = MainStoryboard.instantiateViewController(withIdentifier: "HomeViewController")
let MainTBC = MainStoryboard.instantiateViewController(withIdentifier: "MainTabBarController")


//MARK:- Screen Specs
let ScreenSize = UIScreen.main().bounds.size
let ScreenScale = UIScreen.main().scale
