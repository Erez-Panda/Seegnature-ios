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
    func handleSessionRequest(_ currentVC: UIViewController, sessionId: String, capabilities: [String: AnyObject], isRep: Bool = false, resources: Array<Dictionary<String, AnyObject>>?) {
        
        let val = SeegnatureActions()
        showSpinner("Initializing session")
        
        val.getSessionInfo(sessionId) {
            (result: Bool) in
            if (result == false) {
                hideSpinner()
                showAlert(currentVC, title: "Error", message: "Session id \(sessionId) not found")
            } else {
                val.startSession(currentVC.view, dictionary: capabilities as NSDictionary, isRep: isRep, resources: resources) {
                    currentVC.navigationController?.isNavigationBarHidden = true
                    hideSpinner()
                }
            }
        }
    }
    
    func cleanDictionaryNil(_ dictionary: NSDictionary) -> Dictionary<String, AnyObject>{
        var clean = dictionary as! Dictionary<String, AnyObject>
        for (key, value) in clean {
            if value as? String == nil {
                if value as? NSNumber == nil{
                    clean[key] = "" as AnyObject
                }
            }
        }
        return clean
    }

    func saveCredentials(_ username: String, password: String) {
        UserDefaults.standard.set(["username": username, "password": password], forKey: "credentials")
        UserDefaults.standard.synchronize()
    }
    
    func saveUserData(_ userData: NSDictionary) -> Void{
        UserDefaults.standard.set(userData["user"], forKey: DataType.User.rawValue)
        var userInfo = userData as! Dictionary<String, AnyObject>
        userInfo = cleanDictionaryNil(userInfo as NSDictionary)
        UserDefaults.standard.set(userInfo, forKey: DataType.Profile.rawValue)
        UserDefaults.standard.synchronize()
    }
    
    func getUserData(_ type:DataType) -> NSMutableDictionary{
        let defaultUser = UserDefaults.standard
        if let userProfile : AnyObject = defaultUser.object(forKey: type.rawValue) as AnyObject {
            return userProfile as! NSMutableDictionary
        }
        return [:]
    }
    
    func cleanUserData() -> Void{
//        ViewUtils.profileImage = nil
        let appDomain = Bundle.main.bundleIdentifier
        UserDefaults.standard.removePersistentDomain(forName: appDomain!)
        UserDefaults.standard.synchronize()
    }

}

func slideInMenu (_ viewController: UIViewController){
    let menuView = viewController.storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
    
    let grayView = UIView()
    grayView.frame = CGRect(x: 0.0, y: 0.0, width: viewController.view.frame.width, height: viewController.view.frame.height)
    grayView.backgroundColor = UIColor.black
    grayView.alpha = 0.5
    
    
    menuView.previousViewController = viewController
    menuView.grayView = grayView
    menuView.view.frame.origin.x = -1 * menuView.view.frame.size.width
    let parent = viewController.parent
    parent?.addChildViewController(menuView)
    parent?.view.addSubview(menuView.view)
    parent?.view.addSubview(grayView)
    parent?.view.bringSubview(toFront: menuView.view)
    menuView.view.alpha = 0.0
    UIView.animate(withDuration: 0.5, animations: { () -> Void in
        menuView.view.frame.origin.x = 0
        menuView.view.alpha = 1
        
    })
    
    // MARK: network methods
    
    func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
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
    
    func getDataFromUrl(_ urL:URL, completion: @escaping ((_ data: Data?) -> Void)) {
        URLSession.shared.dataTask(with: urL, completionHandler: { (data, response, error) in
            completion(data)
            }) .resume()
    }
    
}

