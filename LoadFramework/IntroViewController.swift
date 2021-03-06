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
    let seegnatureManager = SeegnatureActions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerKeyboardNotifications()

        UIEventRegister.tapRecognizer(self, action: #selector(IntroViewController.closeKeyboard))
        
        setBordersForTextField(self.callIdTextField, borderWidth: 1.0)
        setBordersForTextField(self.loginButton, borderWidth: 1.0)
        
        setLabelsSize()
        
        addScreenRotationNotification()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.post(Notification(name: seegnatureManager.homeScreenReadyName, object: self))
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
        self.view.bringSubview(toFront: self.titleTextView)
        
        seegnatureLabel.attributedText = getAttrText(" Seegnature ", color: UIColor.white, size: 42.0, fontName:"OpenSans-Semibold")
    }
    
    
    
    // MARK: screen rotation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        closeKeyboard()
    }
    func addScreenRotationNotification() {
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "screenRotated", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    func screenRotated() {
        Timer.scheduledTimer(timeInterval: TimeInterval(0.1), target: self, selector: #selector(IntroViewController.rotateScreen), userInfo: nil, repeats: false)
    }
    
    func rotateScreen() {
//        self.callIdTextField.becomeFirstResponder()
    }
    
    // MARK: textfield methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        if (textField.text != ""){
            
            let capabilities = ["video_enabled": false, "ask_for_video": true]
            AppManager.sharedInstance.handleSessionRequest(self, sessionId: textField.text!, capabilities: capabilities as [String : AnyObject], isRep: false, resources: nil)
        }
        
        textField.attributedText = getAttrText("I have a call ID", color: uicolorFromHex(0x67CA94), size: 18.0)
        textField.resignFirstResponder()
        
        return true
    }
    
    
    // MARK: keyboard methods
    
    func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(IntroViewController.keyboardWillShown(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(IntroViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShown(_ sender: Notification){
        let info: NSDictionary = sender.userInfo! as NSDictionary
        let value: NSValue = info.value(forKey: UIKeyboardFrameBeginUserInfoKey) as! NSValue
        let keyboardSize: CGSize = value.cgRectValue.size
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.view.frame.origin.y  -= keyboardSize.height
        })
        
    }
    
    func keyboardWillHide(){
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.view.frame.origin.y  = 0.0
        })
    }
    
    func closeKeyboard(){
        callIdTextField.attributedText = getAttrText("I have a call ID", color: uicolorFromHex(0x67CA94), size: 18.0)
        callIdTextField.resignFirstResponder()
    }

}

