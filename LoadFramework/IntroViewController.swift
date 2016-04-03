//
//  ViewController.swift
//  LoadFramework
//
//  Created by Moshe Krush on 09/02/16.
//  Copyright © 2016 Moshe Krush. All rights reserved.
//

import UIKit
import SeegnatureSDK

class IntroViewController: UIViewController {

    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var callIdTextField: UITextField!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var seegnatureLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerKeyboardNotifications()

        UIEventRegister.tapRecognizer(self, action: "closeKeyboard")
        
        setBordersForTextField(self.callIdTextField, borderWidth: 1.0)
        setBordersForTextField(self.loginButton, borderWidth: 1.0)
        
        setLabelsSize()
        
        addScreenRotationNotification()

    }
    
    override func viewDidAppear(animated: Bool) {
//        AppManager.sharedInstance.handleSessionRequest(self, sessionId: "1763", capabilities: ["video_enabled": true, "ask_for_video": true], resources: nil)
//        AppManager.sharedInstance.handleSessionRequest(self, sessionId: "392", capabilities: ["video_enabled": true, "ask_for_video": true], resources: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let layers = callIdTextField.layer.sublayers{
            for layer in layers {
                layer.frame.size.width = callIdTextField.frame.width
            }
        }
    }

    func setLabelsSize() {
        
        self.titleTextView.attributedText = getAttrText("Review, edit and sign documents during a real time video call", color: uicolorFromHex(0x45445A), size: 28.0, fontName:"OpenSans-Semibold", addShadow: true)
        self.view.bringSubviewToFront(self.titleTextView)
        
        seegnatureLabel.attributedText = getAttrText(" Seegnature ", color: UIColor.whiteColor(), size: 42.0, fontName:"OpenSans-Semibold")
    }
    
    
    
    // MARK: screen rotation
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        closeKeyboard()
    }
    func addScreenRotationNotification() {
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "screenRotated", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    func screenRotated() {
        NSTimer.scheduledTimerWithTimeInterval(NSTimeInterval(0.1), target: self, selector: Selector("rotateScreen"), userInfo: AnyObject?(), repeats: false)
    }
    
    func rotateScreen() {
//        self.callIdTextField.becomeFirstResponder()
    }
    
    // MARK: textfield methods
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {

        if (textField.text != ""){
            
            let capabilities = ["video_enabled": true, "ask_for_video": true]
            AppManager.sharedInstance.handleSessionRequest(self, sessionId: textField.text!, capabilities: capabilities, isRep: false, resources: nil)
        }
        
        textField.attributedText = getAttrText("I have a call ID", color: uicolorFromHex(0x67CA94), size: 18.0)
        textField.resignFirstResponder()
        
        return true
    }
    
    
    // MARK: keyboard methods
    
    func registerKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShown:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide"), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShown(sender: NSNotification){
        let info: NSDictionary = sender.userInfo!
        let value: NSValue = info.valueForKey(UIKeyboardFrameBeginUserInfoKey) as! NSValue
        let keyboardSize: CGSize = value.CGRectValue().size
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.view.frame.origin.y  -= keyboardSize.height
        })
        
    }
    
    func keyboardWillHide(){
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.view.frame.origin.y  = 0.0
        })
    }
    
    func closeKeyboard(){
        callIdTextField.attributedText = getAttrText("I have a call ID", color: uicolorFromHex(0x67CA94), size: 18.0)
        callIdTextField.resignFirstResponder()
    }

}

