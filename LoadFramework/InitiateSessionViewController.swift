//
//  InitiateSessionViewController.swift
//  Seegnature
//
//  Created by Moshe Krush on 12/03/16.
//  Copyright © 2016 Moshe Krush. All rights reserved.
//

import UIKit
import MobileCoreServices
import SeegnatureSDK

class InitiateSessionViewController: UIViewController, FileSelectorDelegate, UITextFieldDelegate{
    
    @IBOutlet weak var inputsView: UIView!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var sessionId: UITextField!
    @IBOutlet weak var startSessionButton: UIButton!
    
    @IBOutlet weak var emailIcon: NIKFontAwesomeButton!
    @IBOutlet weak var phoneIcon: NIKFontAwesomeButton!
    @IBOutlet weak var documentIcon: NIKFontAwesomeButton!
    var keyboardVisable = false
    var selectedFile: File?
    var fileSelector: FileSelector!
    
    let seegnatureManager = SeegnatureActions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        inputsView?.borderView(1, borderColor: uicolorFromHex(0xBBBAC1), borderRadius: 3)
        startSessionButton.borderView(0, borderColor: UIColor.clearColor(), borderRadius: 3)
        fileSelector = FileSelector(viewController: self)
        fileSelector.delegate = self

        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShown:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide"), name: UIKeyboardWillHideNotification, object: nil)
        UIEventRegister.tapRecognizer(self, action:"closeKeyboard")

        self.navigationItem.titleView = UIImageView(image: UIImage(named: "navigation_bar_logo"))

    }

    func closeKeyboard(){
        email.resignFirstResponder()
        phone.resignFirstResponder()
        sessionId.resignFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: screen rotation
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        closeKeyboard()
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if (isValidEmail(self.email.text!)){
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if (textField == self.phone){
            if phone.text?.characters.first != "+"{
                phone.text = "+"+phone.text!
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == self.email){
            if (isValidEmail(self.email.text!)){
                emailIcon.color = defaultbuttonColor
                self.phone.becomeFirstResponder()
            } else {
                emailIcon.color = uicolorFromHex(0xBBBAC1)
            }
        } else if (textField == self.phone){
            if phone.text != "" && phone.text?.characters.first != "+"{
                phoneIcon.color = UIColor.redColor()
            } else {
                phoneIcon.color = defaultbuttonColor
            }
            
            textField.resignFirstResponder()
        } else if textField == self.sessionId && textField.text != ""{
            textField.resignFirstResponder()
            self.openCallScreen(textField.text!, resources: nil)
        }
        return true
    }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let isValid = emailTest.evaluateWithObject(testStr)
        return isValid
    }
    
    func keyboardWillShown(sender: NSNotification) {
        
        let info: NSDictionary = sender.userInfo!
        let value: NSValue = info.valueForKey(UIKeyboardFrameBeginUserInfoKey) as! NSValue
        let keyboardSize: CGSize = value.CGRectValue().size
        
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.view.frame.origin.y  -= keyboardSize.height - self.inputsView.frame.origin.y
            if self.sessionId.isFirstResponder() {
                self.view.frame.origin.y -= self.sessionId.frame.size.height
            }
        })
        

    }
    
    func keyboardWillHide(){
        UIView.animateWithDuration(0.1, animations: { () -> Void in
            self.view.frame.origin.y  = 0.0
        })
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
    @IBAction func selectFile(sender: UIButton) {
        fileSelector.selectFile(sender)
    }
    
    func fileSelected(file: File) {
        if file.mimetype == "invalid" {
            return
            //show error
        }
        selectedFile = file
        if let name = file.name{
            dispatch_async(dispatch_get_main_queue()){
                self.uploadButton.setTitle(name, forState: UIControlState.Normal)
                self.uploadButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
                self.documentIcon.color = defaultbuttonColor
            }
        }
    }
    
    @IBAction func openMenu(sender: AnyObject) {
        slideInMenu(self)
    }
    
    func resetForm(){
        activity.stopAnimating()
        self.email.text = ""
        self.phone.text = ""
        selectedFile = nil
        emailIcon.color = uicolorFromHex(0xBBBAC1)
        phoneIcon.color = uicolorFromHex(0xBBBAC1)
        documentIcon.color = uicolorFromHex(0xBBBAC1)
        uploadButton.setTitle("Document", forState: UIControlState.Normal)
        uploadButton.setTitleColor(uicolorFromHex(0xD0D0D0), forState: UIControlState.Normal)
        self.statusLabel.hidden = true
        self.sessionId.text = ""
        self.sessionId.attributedText = getAttrText("I have a session ID", color: uicolorFromHex(0x67CA94), size: 17.0)
        
    }
    
    func validateForm() -> Bool{
        if nil==selectedFile?.data || nil==selectedFile?.name{
            documentIcon.color = UIColor.redColor()
            return false
        }
        
        if !isValidEmail(email.text!) && email.text != ""{
            emailIcon.color = UIColor.redColor()
            return false
        }
        
        if phone.text != "" && phone.text?.characters.first != "+"{
            phoneIcon.color = UIColor.redColor()
            return false
        }
        
        if phone.text == "" && email.text == ""{
            emailIcon.color = UIColor.redColor()
            return false
        }
        
        return true
    }
    
    func startSession(file: File){
        //uploading file...
        dispatch_async(dispatch_get_main_queue()){
            self.statusLabel.text = "uploading file..."
            self.statusLabel.hidden = false
        }
        
        seegnatureManager.uploadFile(file.data!, fileName: file.name!, mimeType: file.mimetype) { (result) -> Void in
            if let fileId = result["id"] as? Int{
                let fileUrl = result["url"] as! String
                // creating new contact...
                dispatch_async(dispatch_get_main_queue()){
                    self.statusLabel.text = "creating new contact..."
                }
                var email = "no@mail.com"
                if nil != self.email.text && self.email.text != ""{
                    email = self.email.text!
                }
                
                let contact = ["first_name": "John",
                    "last_name": "Doe",
                    "email": email,
                    "phone": self.phone.text!
                ]
                self.seegnatureManager.createNewContact(contact, completion: { (result) -> Void in
                    // processing resource...
                    dispatch_async(dispatch_get_main_queue()){
                        self.statusLabel.text = "processing resource..."
                    }
                    if let contactId = result["id"] as? Int{
                        let res : Dictionary<String, AnyObject> = ["name": "\(file.name!) for \(self.email.text!)",
                            "type": 1,
                            "url": fileUrl,
                            "file": fileId
                        ]
                        self.seegnatureManager.newResource(res, completion: { (result) -> Void in
                            if let resId = result["id"] as? Int{
                                let newRes = result
                                //creating session..
                                dispatch_async(dispatch_get_main_queue()){
                                    self.statusLabel.text = "creating session.."
                                }
                                let userId = AppManager.sharedInstance.getUserData(AppManager.DataType.Profile)["id"] as! NSNumber
                                let date = NSDate()
                                let call :Dictionary<String, AnyObject> = ["caller": userId,
                                    "title": "Call created by rep",
                                    "start": date.convertToServerString(),
                                    "end": date.dateByAddingTimeInterval(1).convertToServerString(),
                                    "guest_callee": contactId,
                                    "type": "sign-document",
                                    "related_resource": resId]
                                self.seegnatureManager.newGuestCall(call, completion: { (result) -> Void in
                                    if let id = result["id"] as? NSNumber{
                                        self.openCallScreen(id.stringValue, resources: [newRes as! Dictionary<String, AnyObject>])
                                    }
                                    
                                })
                            }
                        })
                    }
                })
            }
        }
    }
    
    func openCallScreen(callId: String, resources: Array<Dictionary<String, AnyObject>>?){
//        dispatch_async(dispatch_get_main_queue()){
//            self.statusLabel.text = "opening call.."
//            self.statusLabel.hidden = false
//        }
        
        let defaultCapabilities = ["video_enabled": true, "ask_for_video": true]
        
        AppManager.sharedInstance.handleSessionRequest(self, sessionId: callId, capabilities: defaultCapabilities, isRep: true, resources: resources)
        
        self.resetForm()
        
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            appDelegate.window?.rootViewController = self
        }
    }
    
    @IBAction func startSession(sender: AnyObject) {
        if validateForm() {
            activity.startAnimating()
            startSession(selectedFile!)
        }
    }
}

