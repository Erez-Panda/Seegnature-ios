//
//  ViewController.swift
//  Panda4doctor
//
//  Created by Erez on 11/23/14.
//  Copyright (c) 2014 Erez. All rights reserved.
//

import UIKit
import SeegnatureSDK

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var liveMedTitleLabel: UILabel!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    
    var keyboardVisable = false
    let seegnatureManager = SeegnatureActions()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillShown), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
        UIEventRegister.tapRecognizer(self, action:#selector(LoginViewController.closeKeyboard))
        liveMedTitleLabel.attributedText = getAttrText("Seegnature", color: uicolorFromHex(0x8E8DA2), size: 30.0, fontName: "OpenSans-Semibold" )
        
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    override func viewDidLayoutSubviews(){
        super.viewDidLayoutSubviews()
        loginView.layoutIfNeeded()
        loginButton.borderView(1.0, borderColor: UIColor.clearColor(), borderRadius: 3.0)
        loginView.borderView(1.0, borderColor: uicolorFromHex(0xDFDFDF), borderRadius: 3.0)
        let middleBorder = CALayer()
        
        middleBorder.frame = CGRectMake(0.0, loginView.frame.size.height/2, loginView.frame.size.width, 1.0);
        middleBorder.backgroundColor = uicolorFromHex(0xDFDFDF).CGColor
        loginView.layer.addSublayer(middleBorder)
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        return false
//        if identifier == "moveToRepMainScreenSegue" {
//            return
//        }
    }
    
    // MARK: keyboard methods

    func closeKeyboard(){
        userEmail.resignFirstResponder()
        userPassword.resignFirstResponder()
    }

    func keyboardWillShown(){
        
        if (!keyboardVisable){
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.view.frame.origin.y  -= 30
            })
        }
        keyboardVisable = true
    }
    
    func keyboardWillHide(){
        
        if (keyboardVisable){
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.view.frame.origin.y = 0.0
            })
        }
        keyboardVisable = false
    }
    
    // MARK: textifeld delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == self.userEmail){
            self.userPassword.becomeFirstResponder()
        } else if (textField == self.userPassword){
            self.login(self.loginButton)
            textField.resignFirstResponder()
        }
        return true
    }
    
    // MARK: buttons methods
    
    @IBAction func login(sender: UIButton) {
        
        showSpinner("Verifying Credentials")
        
        seegnatureManager.login(userEmail.text!, password: userPassword.text!) {
            (result: Bool) in
            
            hideSpinner()

            if (result == false) {
                showAlert(self, title: "Login Error", message: "Your username and password do not match")
            } else {
                AppManager.sharedInstance.saveCredentials(self.userEmail.text!, password: self.userPassword.text!)
                
                showSpinner("Getting User Details")
                
                self.seegnatureManager.getUserDetails() {
                    (result: NSDictionary) in
                    hideSpinner()
                    if let val = result["type"] as? String where val == "MEDREP" {
                        AppManager.sharedInstance.saveUserData(result)
                        AppManager.sharedInstance.isLoggedIn = true
                        dispatch_async(dispatch_get_main_queue()){
                            self.performSegueWithIdentifier("moveToRepMainScreenSegue", sender: AnyObject?())
                        }
                    } else {
                        //not a rep, don't login
                        showAlert(self, title: "Login Error", message: "Your username and password do not match")
                    }
                    if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                        appDelegate.loginComplete()
                    }
                }
            }
        }
    }
    
    @IBAction func back(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func forgotPassword(sender: AnyObject) {
        if (isValidEmail(userEmail.text!)){
            seegnatureManager.resetUserPassword(["email": userEmail.text!], completion: { (result) -> Void in
                if let error = result["error"] as? String {
                    dispatch_async(dispatch_get_main_queue()){
                        print(error)
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()){
                        showAlert(self, title: "Reset password email has been sent", message: "Please follow email instructions to reset your password")
                    }
                }
            })
        } else {
            showAlert(self, title: "Missing Email", message: "Please enter your email in the \"Email\" field")
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let isValid = emailTest.evaluateWithObject(testStr)
        return isValid && !testStr.isEmpty
        
    }

}

