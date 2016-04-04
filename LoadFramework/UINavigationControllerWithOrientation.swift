//
//  UINavigationControllerWithOrientation.swift
//  Panda4doctor
//
//  Created by Erez on 12/17/14.
//  Copyright (c) 2014 Erez. All rights reserved.
//

import UIKit

class UINavigationControllerWithOrientation: UINavigationController {

//    override func shouldAutorotate() -> Bool {
//        return self.topViewController!.shouldAutorotate()
//    }
    
//    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
//        return self.topViewController!.supportedInterfaceOrientations()
//    }
    
//    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
//        return self.topViewController!.preferredInterfaceOrientationForPresentation()
//    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }

}
