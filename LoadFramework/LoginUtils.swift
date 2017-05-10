//
//  LoginUtils.swift
//  Panda4doctor
//
//  Created by Erez on 1/1/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import LocalAuthentication
import UIKit

@objc protocol LoginDelegate{
    @objc optional func loginComplete()
}

struct LoginUtils {
    static var delegate:LoginDelegate?
    static var isLoggedIn = false
    static func showPasswordAlert() {
        
    }
    
    static func authenticateUser(completion: @escaping (_ result: Bool) -> Void) -> Void{
        completion(false)
//        // Get the local authentication context.
//        let context = LAContext()
//        
//        // Declare a NSError variable.
//        var error: NSError?
//        
//        // Set the reason string that will appear on the authentication alert.
//        let reasonString = "Authentication is needed to access Seegnature."
//        
//        // Check if the device can evaluate the policy.
//        do {
//            try context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error:nil)
//            [context .evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString, reply: { (success: Bool, evalPolicyError: NSError?) -> Void in
//                
//                if success {
//                    completion(true)
//                    return
//                }
//                else{
//                    // If authentication failed then show a message to the console with a short description.
//                    // In case that the error is a user fallback, then show the password alert view.
//                    print(evalPolicyError?.localizedDescription, terminator: "")
//                    
//                    switch evalPolicyError!.code {
//                        
//                    case LAError.systemCancel.rawValue:
//                        print("Authentication was cancelled by the system", terminator: "")
//                        
//                    case LAError.userCancel.rawValue:
//                        print("Authentication was cancelled by the user", terminator: "")
//                        
//                    case LAError.userFallback.rawValue:
//                        print("User selected to enter custom password", terminator: "")
//                        self.showPasswordAlert()
//                        
//                    default:
//                        print("Authentication failed", terminator: "")
//                        self.showPasswordAlert()
//                    }
//                    completion(false)
//                }
//                
//            } as! (Bool, Error?) -> Void)]
//        } catch let error1 as NSError {
//            error = error1
//            // If the security policy cannot be evaluated then show a short message depending on the error.
//            switch error!.code{
//                
//            case LAError.touchIDNotEnrolled.rawValue:
//                print("TouchID is not enrolled", terminator: "")
//                
//            case LAError.passcodeNotSet.rawValue:
//                print("A passcode has not been set", terminator: "")
//                
//            default:
//                // The LAError.TouchIDNotAvailable case.
//                print("TouchID not available", terminator: "")
//            }
//            
//            // Optionally the error description can be displayed on the console.
//            print(error?.localizedDescription, terminator: "")
//            completion(true)
//            return
//            // Show the custom alert view to allow users to enter the password.
//            //self.showPasswordAlert()
//            //completion(result: false)
//        }
    }
    
    static func showLoginError(){
        DispatchQueue.main.async(){
            if let vc = getTopViewController() {
                showAlert(vc, title: "Login Error", message: "Your username and password do not match")
            }
        }
    }
    
    static func login(username: String, password: String, sender: UIViewController, successSegue: String, completion: (_ result: Bool) -> Void) -> Void{
        UserDefaults.standard.set(["username": username, "password": password], forKey: "credentials")
        UserDefaults.standard.synchronize()
    }
    
}
