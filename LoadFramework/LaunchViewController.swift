//
//  LanuchViewController.swift
//  Panda4doctor
//
//  Created by Erez Haim on 2/5/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit
import SeegnatureSDK

class LaunchViewController: UIViewController {
    var introViewController: IntroViewController?
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func showIntro(){
        dispatch_async(dispatch_get_main_queue()){
            self.introViewController = self.storyboard?.instantiateViewControllerWithIdentifier("IntroViewController") as? IntroViewController
            self.presentViewController(self.introViewController!, animated: true, completion: nil)
//            self.addChildViewController(self.introViewController!)
//            self.view.addSubview(self.introViewController!.view)
//            self.introViewController!.didMoveToParentViewController(self)
        }
        NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "LoginFailed", object: nil))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaultUser = NSUserDefaults.standardUserDefaults()
        if let credentials : AnyObject = defaultUser.objectForKey("credentials") {
            LoginUtils.authenticateUser({ (result) -> Void in
                if (result){
                    if let username = credentials["username"] as? String  {
                        if let password = credentials["password"] as? String {
                            let seegnatureManager = SeegnatureActions()
                            seegnatureManager.login(username, password: password) {
                                (result: Bool) in
                                if (!result){
                                    self.showIntro()
                                } else {
                                    NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: "LoginSucceeded", object: nil))
                                    dispatch_async(dispatch_get_main_queue()){
                                        self.performSegueWithIdentifier("launchToRepMainScreenSegue", sender: AnyObject?())
                                    }
                                }
                            }
                        }
                    }
                } else {
                    self.showIntro()
                }
            })
        } else {
            self.showIntro()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        if (!Reachability.isConnectedToNetwork()){
            showAlert(self, title: "Connectivity Error", message: "This application requiers internet connection. Please connect to the internet and reopen application")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
}
