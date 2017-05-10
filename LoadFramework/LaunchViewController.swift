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
        DispatchQueue.main.async{
            self.introViewController = self.storyboard?.instantiateViewController(withIdentifier: "IntroViewController") as? IntroViewController
            self.present(self.introViewController!, animated: true, completion: nil)
//            self.addChildViewController(self.introViewController!)
//            self.view.addSubview(self.introViewController!.view)
//            self.introViewController!.didMoveToParentViewController(self)
        }
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "LoginFailed"), object: nil))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaultUser = UserDefaults.standard
        if let credentials : AnyObject = defaultUser.object(forKey: "credentials") as AnyObject {
            LoginUtils.authenticateUser(completion: { (result) -> Void in
                if (result){
                    if let username = credentials["username"] as? String  {
                        if let password = credentials["password"] as? String {
                            let seegnatureManager = SeegnatureActions()
                            seegnatureManager.login(username, password: password) {
                                (result: Bool) in
                                if (!result){
                                    self.showIntro()
                                } else {
                                    NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "LoginSucceeded"), object: nil))
                                    DispatchQueue.main.async{
                                        self.performSegue(withIdentifier: "launchToRepMainScreenSegue", sender: nil)
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
    
    override func viewDidAppear(_ animated: Bool) {
        if (!Reachability.isConnectedToNetwork()){
            showAlert(self, title: "Connectivity Error", message: "This application requiers internet connection. Please connect to the internet and reopen application")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    
}
