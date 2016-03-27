//
//  AppManager.swift
//  Seegnature
//
//  Created by Moshe Krush on 03/03/16.
//  Copyright © 2016 Moshe Krush. All rights reserved.
//

import Foundation
import UIKit
import SeegnatureSDK

let defaultMainColor = uicolorFromHex(0x464567)
let defaultbuttonColor = uicolorFromHex(0x67CA94)

class AppManager: NSObject {

    var isLoggedIn = false
    
    static let sharedInstance = AppManager()

    // MARK: user methods
    
    enum DataType : String{
        case User = "userData"
        case Profile = "userProfile"
        case Credentials = "credentials"
        case ArticleBookmark = "articleBookmarks"
        case PromotionalBookmark = "promoBookmarks"
        case ArticleRecent = "articleRecents"
        case PromotionalRecent = "promoRecents"
    }
    
    enum ErrorType : String {
        case connectivityError = "Connectivity Error"
        case userNamePasswordError = "Authentication Error"
    }
    
    // MARK: SDK methods
    func handleSessionRequest(currentVC: UIViewController, sessionId: String, capabilities: [String: AnyObject], isRep: Bool = false, resources: Array<Dictionary<String, AnyObject>>?) {
        
        let val = SeegnatureActions()
        
        showSpinner("Initializing session")
        
        val.getSessionInfo(sessionId) {
            (result: Bool) in

            if (result == false) {
                hideSpinner()
                showAlert(currentVC, title: "Error", message: "Session id \(sessionId) not found")
            } else {
                val.startSession(currentVC.view, dictionary: capabilities, isRep: isRep, resources: resources) {
                    currentVC.navigationController?.navigationBarHidden = true
                    hideSpinner()
                }
            }
        }
    }
    
    func cleanDictionaryNil(dictionary: NSDictionary) -> Dictionary<String, AnyObject>{
        var clean = dictionary as! Dictionary<String, AnyObject>
        for (key, value) in clean {
            if value as? String == nil {
                if value as? NSNumber == nil{
                    clean[key] = ""
                }
            }
        }
        return clean
    }

    func saveCredentials(username: String, password: String) {
        NSUserDefaults.standardUserDefaults().setObject(["username": username, "password": password], forKey: "credentials")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func saveUserData(userData: NSDictionary) -> Void{
        NSUserDefaults.standardUserDefaults().setObject(userData["user"], forKey: DataType.User.rawValue)
        var userInfo = userData as! Dictionary<String, AnyObject>
        userInfo = cleanDictionaryNil(userInfo)
        NSUserDefaults.standardUserDefaults().setObject(userInfo, forKey: DataType.Profile.rawValue)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func getUserData(type:DataType) -> NSMutableDictionary{
        let defaultUser = NSUserDefaults.standardUserDefaults()
        if let userProfile : AnyObject = defaultUser.objectForKey(type.rawValue) {
            return userProfile as! NSMutableDictionary
        }
        return [:]
    }
    
    func cleanUserData() -> Void{
//        ViewUtils.profileImage = nil
        let appDomain = NSBundle.mainBundle().bundleIdentifier
        NSUserDefaults.standardUserDefaults().removePersistentDomainForName(appDomain!)
        NSUserDefaults.standardUserDefaults().synchronize()
    }

}

func slideInMenu (viewController: UIViewController){
    let menuView = viewController.storyboard?.instantiateViewControllerWithIdentifier("MenuViewController") as! MenuViewController
    
    let grayView = UIView()
    grayView.frame = CGRectMake(0.0, 0.0, viewController.view.frame.width, viewController.view.frame.height)
    grayView.backgroundColor = UIColor.blackColor()
    grayView.alpha = 0.5
    
    
    menuView.previousViewController = viewController
    menuView.grayView = grayView
    menuView.view.frame.origin.x = -1 * menuView.view.frame.size.width
    let parent = viewController.parentViewController
    parent?.addChildViewController(menuView)
    parent?.view.addSubview(menuView.view)
    parent?.view.addSubview(grayView)
    parent?.view.bringSubviewToFront(menuView.view)
    menuView.view.alpha = 0.0
    UIView.animateWithDuration(0.5, animations: { () -> Void in
        menuView.view.frame.origin.x = 0
        menuView.view.alpha = 1
        
    })
    
    // MARK: network methods
    
    func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        /*
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
        SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0)).takeRetainedValue()
        }
        
        var flags: SCNetworkReachabilityFlags = 0
        if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == 0 {
        return false
        }
        
        let isReachable = (flags & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        */
        return true //(isReachable && !needsConnection) ? true : false
    }
    
    func checkConnection() -> Bool {
        if (!isConnectedToNetwork()){
            if let vc = getTopViewController() {
                showAlert(vc, title: "Connectivity Error", message: "Cannot connect to server, Please check you internet connection")
            }
            return false
        }
        return true
    }
    
    func getDataFromUrl(urL:NSURL, completion: ((data: NSData?) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(urL) { (data, response, error) in
            completion(data: data)
            }.resume()
    }
}

