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
        startSessionButton.borderView(0, borderColor: UIColor.clear, borderRadius: 3)
        fileSelector = FileSelector(viewController: self)
        fileSelector.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(InitiateSessionViewController.keyboardWillShown(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(InitiateSessionViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        UIEventRegister.tapRecognizer(self, action:#selector(InitiateSessionViewController.closeKeyboard))

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
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        closeKeyboard()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (isValidEmail(self.email.text!)){
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if (textField == self.phone){
            if phone.text?.characters.first != "+"{
                phone.text = "+"+phone.text!
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == self.email){
            if (isValidEmail(self.email.text!)){
                emailIcon.color = defaultbuttonColor
                self.phone.becomeFirstResponder()
            } else {
                emailIcon.color = uicolorFromHex(0xBBBAC1)
            }
        } else if (textField == self.phone){
            if phone.text != "" && phone.text?.characters.first != "+"{
                phoneIcon.color = UIColor.red
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
    
    func isValidEmail(_ testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let isValid = emailTest.evaluate(with: testStr)
        return isValid
    }
    
    func keyboardWillShown(_ sender: Notification) {
        
        let info: NSDictionary = sender.userInfo! as NSDictionary
        let value: NSValue = info.value(forKey: UIKeyboardFrameBeginUserInfoKey) as! NSValue
        let keyboardSize: CGSize = value.cgRectValue.size
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.view.frame.origin.y  -= keyboardSize.height - self.inputsView.frame.origin.y
            if self.sessionId.isFirstResponder {
                self.view.frame.origin.y -= self.sessionId.frame.size.height
            }
        })
        

    }
    
    func keyboardWillHide(){
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.view.frame.origin.y  = 0.0
        })
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    @IBAction func selectFile(_ sender: UIButton) {
        fileSelector.selectFile(sender)
    }
    
    func fileSelected(_ file: File) {
        if file.mimetype == "invalid" {
            return
            //show error
        }
        selectedFile = file
        if let name = file.name{
            DispatchQueue.main.async{
                self.uploadButton.setTitle(name, for: UIControlState())
                self.uploadButton.setTitleColor(UIColor.black, for: UIControlState())
                self.documentIcon.color = defaultbuttonColor
            }
        }
    }
    
    @IBAction func openMenu(_ sender: AnyObject) {
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
        uploadButton.setTitle("Document", for: UIControlState())
        uploadButton.setTitleColor(uicolorFromHex(0xD0D0D0), for: UIControlState())
        self.statusLabel.isHidden = true
        self.sessionId.text = ""
        self.sessionId.attributedText = getAttrText("I have a session ID", color: uicolorFromHex(0x67CA94), size: 17.0)
        
    }
    
    func validateForm() -> Bool{
        if nil==selectedFile?.data || nil==selectedFile?.name{
            documentIcon.color = UIColor.red
            return false
        }
        
        if !isValidEmail(email.text!) && email.text != ""{
            emailIcon.color = UIColor.red
            return false
        }
        
        if phone.text != "" && phone.text?.characters.first != "+"{
            phoneIcon.color = UIColor.red
            return false
        }
        
        if phone.text == "" && email.text == ""{
            emailIcon.color = UIColor.red
            return false
        }
        
        return true
    }
    
    func startSession(_ file: File){
        //uploading file...
        DispatchQueue.main.async{
            self.statusLabel.text = "uploading file..."
            self.statusLabel.isHidden = false
        }
        
        seegnatureManager.uploadFile(file.data!, fileName: file.name!, mimeType: file.mimetype) { (result) -> Void in
            if let fileId = result["id"] as? Int{
                let fileUrl = result["url"] as! String
                // creating new contact...
                DispatchQueue.main.async{
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
                self.seegnatureManager.createNewContact(contact as Dictionary<String, AnyObject>, completion: { (result) -> Void in
                    // processing resource...
                    DispatchQueue.main.async{
                        self.statusLabel.text = "processing resource..."
                    }
                    if let contactId = result["id"] as? Int{
                        let res : Dictionary<String, AnyObject> = ["name": "\(file.name!) for \(self.email.text!)" as AnyObject,
                            "type": 1 as AnyObject,
                            "url": fileUrl as AnyObject,
                            "file": fileId as AnyObject
                        ]
                        self.seegnatureManager.newResource(res, completion: { (result) -> Void in
                            if let resId = result["id"] as? Int{
                                let newRes = result
                                //creating session..
                                DispatchQueue.main.async{
                                    self.statusLabel.text = "creating session.."
                                }
                                let userId = AppManager.sharedInstance.getUserData(AppManager.DataType.Profile)["id"] as! NSNumber
                                let date = Date()
                                let call :Dictionary<String, AnyObject> = ["caller": userId,
                                    "title": "Call created by rep" as AnyObject,
                                    "start": date.convertToServerString() as AnyObject,
                                    "end": date.addingTimeInterval(1).convertToServerString() as AnyObject,
                                    "guest_callee": contactId as AnyObject,
                                    "type": "sign-document" as AnyObject,
                                    "related_resource": resId as AnyObject]
                                self.seegnatureManager.newGuestCall(call, completion: { (result) -> Void in
                                    if let id = result["uuid"] as? String{
                                        self.openCallScreen(id, resources: [newRes as! Dictionary<String, AnyObject>])
                                    }
                                    
                                })
                            }
                        })
                    }
                })
            }
        }
    }
    
    func openCallScreen(_ callId: String, resources: Array<Dictionary<String, AnyObject>>?){
//        dispatch_async(dispatch_get_main_queue()){
//            self.statusLabel.text = "opening call.."
//            self.statusLabel.hidden = false
//        }
        
        let defaultCapabilities = ["video_enabled": true, "ask_for_video": true]
        AppManager.sharedInstance.handleSessionRequest(self, sessionId: callId, capabilities: defaultCapabilities as [String : AnyObject], isRep: true, resources: resources)
        
        self.resetForm()

    }
    
    @IBAction func startSession(_ sender: AnyObject) {
        if validateForm() {
            activity.startAnimating()
            startSession(selectedFile!)
        }
    }
}

