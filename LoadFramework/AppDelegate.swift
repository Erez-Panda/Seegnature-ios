//
//  AppDelegate.swift
//  LoadFramework
//
//  Created by Moshe Krush on 09/02/16.
//  Copyright © 2016 Moshe Krush. All rights reserved.
//

import UIKit
import SeegnatureSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, LoginDelegate {

    var window: UIWindow?
    var token: String?
    let seegnatureManager = SeegnatureActions()
    var loggedin: Bool?
    var notificationCallId: String?
    var callInfoId: String?
    var inquiryId: NSNumber?
    var newCallId: NSNumber?
    var homeVC: IntroViewController?
    var didOpenCall = false
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = uicolorFromHex(0xffffff)
        navigationBarAppearace.barTintColor = defaultMainColor
        
        // change navigation item title color
        navigationBarAppearace.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.whiteColor()]

        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.lightGrayColor()], forState:.Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: defaultbuttonColor], forState:.Selected)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loginSucceeded", name: "LoginSucceeded", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loginFailed", name: "LoginFailed", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "homeScreenReady:", name: "HomeScreenReady", object: nil)
        
        application.statusBarHidden = true
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        let urlParams = url.getKeyVals()
        if let callId = urlParams?["call_id"]{
            notificationCallId = callId
            if self.homeVC != nil {
                openCallById(callId)
                didOpenCall = true
            }
        }
        return true
    }
    
    func openCallById(callId: String) {
        if nil != loggedin{
            if let VC = getTopViewController() {
                dispatch_async(dispatch_get_main_queue()){
                    self.window!.rootViewController = self.homeVC
                    AppManager.sharedInstance.handleSessionRequest(VC, sessionId: callId, capabilities: ["video_enabled": true, "ask_for_video": true], resources: nil)
                }
            }
        } else {
            notificationCallId = callId
        }
    }
    
    func loginSucceeded(){
        loggedin = true
        if (notificationCallId != nil){
            openCallById(notificationCallId!)
        }
    }
    
    func loginFailed(){
        loggedin = false
        if (notificationCallId != nil){
            openCallById(notificationCallId!)
        }
    }
    
    func loginComplete() {
        if let token = self.token{
            self.seegnatureManager.sendDeviceToken(token)
        }
    }
    
    func homeScreenReady(notification: NSNotification){
        if let vc = notification.object as? IntroViewController{
            homeVC = vc
        }
        if ((didOpenCall == false) && (notificationCallId != nil)) {
            openCallById(notificationCallId!)
            didOpenCall = true
        }
    }
    
}


