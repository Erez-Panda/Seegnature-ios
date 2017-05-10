//
//  MenuViewController.swift
//  Panda4doctor
//
//  Created by Erez on 1/28/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit
import SeegnatureSDK

class MenuViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    var previousViewController: UIViewController!
    var grayView : UIView?
    var isDragging = false
    var startPoint: CGPoint?
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var userNameLabel: UILabel!
    var user: NSDictionary?
    var menuItems = ["About", "Logout"]
    //var menuItems = ["Home", "Profile", "Settings", "Support", "About", "Logout"]
    //var subMenuItems = ["Video Calls", "Articles", "Promotional Materials", "Medical Inquiries"]
    //var subMenuImages = ["menu_icon_video_call", "menu_icon_articles", "menu_icon_promotional", "menu_icon_medical_letters"]
    //var menuIcons = ["home_icon", "profile_icon", "settings_icon", "support_icon" ,"about_icon","logout_icon"]
    var menuIcons = ["about_icon","logout_icon"]
    var menuOpen = false
    var tableCellNumber = 0
    var selectedIndex: Int?
    var closing = false
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bg_image: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    let seegnatureManager = SeegnatureActions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getProfileImage { (result) -> Void in
            self.profileImageView.image = result
        }
        user = AppManager.sharedInstance.getUserData(AppManager.DataType.User)

        tableCellNumber = self.menuItems.count
        profileImageView.roundView(2.0, borderColor: defaultbuttonColor)

        let firstName = user?["first_name"] as! String
        let lastName = user?["last_name"] as! String
        userNameLabel.text = firstName + " " + lastName
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.separatorInset = UIEdgeInsets.zero
        /*
        // Add Border
        var leftBorder = CALayer()
        leftBorder.frame = CGRectMake(self.bg_image.frame.size.width+36, 0.0, 1.0, self.view.frame.size.height);
        leftBorder.backgroundColor = ColorUtils.buttonColor().CGColor
        self.view.layer.addSublayer(leftBorder)
        */
        // Do any additional setup after loading the view.
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getProfileImage(_ completion: @escaping (_ result: UIImage) -> Void) -> Void{
        if ((profileImageView.image) != nil){
            completion(profileImageView.image!)
        } else {
            let defaultUser = UserDefaults.standard
            if let userProfile : AnyObject = defaultUser.object(forKey: "userProfile") as AnyObject {
                if let imageFile = userProfile["image_file"] as? NSNumber{
                    getImageFile(imageFile, completion: { (result) -> Void in
                        self.profileImageView.image = result
                        completion(result)
                    })
                }
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableCellNumber
    }
    
    /*
    func loadExpendedTable(tableView: UITableView, index: Int)-> UITableViewCell{
    var i = index
    if (index > 0 && index <= self.subMenuItems.count){
    let cell = tableView.dequeueReusableCellWithIdentifier("subMenuCell") as! MenuTableViewCell
    cell.rightButton.hidden = true
    var iconName = self.subMenuImages[index-1]
    cell.leftIconView.image = UIImage(named: iconName)
    cell.label.text = self.subMenuItems[index-1]
    cell.label.textColor = ColorUtils.buttonColor()
    if iOS8 {cell.layoutMargins = UIEdgeInsetsZero}
    cell.selectionStyle = UITableViewCellSelectionStyle.None
    return cell
    }
    let cell = tableView.dequeueReusableCellWithIdentifier("menuCell") as! MenuTableViewCell
    if (index != 0){
    cell.rightButton.hidden = true
    i = index - self.subMenuItems.count
    }
    var iconName = self.menuIcons[i]
    cell.leftIconView.image = UIImage(named: iconName)
    cell.label.text = self.menuItems[i]
    if iOS8 {cell.layoutMargins = UIEdgeInsetsZero}
    cell.selectionStyle = UITableViewCellSelectionStyle.None
    return cell
    }
    */
    
    func loadCollapseTable(_ tableView: UITableView, index: Int)-> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell") as! MenuTableViewCell
        let iconName = self.menuIcons[index]
        cell.leftIconView.image = UIImage(named: iconName)
        cell.leftIconView.isHidden = false
        cell.label.text = self.menuItems[index]
        cell.label.textColor = UIColor.black
        cell.rightButton.isHidden = true;
        /*
        if (index != 0){
        cell.rightButton.hidden = true;
        } else {
        cell.rightButton.tag = index
        cell.rightButton.addTarget(self, action: "toggleMenu:", forControlEvents: UIControlEvents.TouchUpInside)
        }
        */

        return cell
    }
    /*
    func toggleMenu(sender: UIButton!) {
    //sender.tag
    menuOpen = !menuOpen
    if (menuOpen){
    tableCellNumber = self.menuItems.count + self.subMenuItems.count
    } else {
    tableCellNumber = self.menuItems.count
    }
    tableView.reloadData()
    
    /* Maybe use:
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:(NSArray *) paths withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
    */
    }
    */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return loadCollapseTable(tableView, index: indexPath.row)
        /*
        if (menuOpen){
        return loadExpendedTable(tableView, index: indexPath.row)
        }else {
        return loadCollapseTable(tableView, index: indexPath.row)
        }
        */
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        openMenuItem(index)
    }
    
    func openMenuItem(_ index: Int){
        /*
        if (index == 1){
        closeMenuAndShowViewController("ProfileUIViewController")
        }
        if (index == 2){
        closeMenuAndShowViewController("SettingsViewController")
        }
        if (index == 3){
        closeMenuAndShowViewController("SupportViewController")
        }
        */
        if (index == 0){
            
            let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject
            let version = nsObject as! String
            if let vc = getTopViewController() {
                showAlert(vc, title: "Seegnature", message: "Version: \(version)")
            }
        } else if (index == 1){
            seegnatureManager.logout() {result -> Void in
                AppManager.sharedInstance.cleanUserData()
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "IntroViewController") as! IntroViewController
                self.present(vc, animated: true, completion: nil)
            }
        } else {
            self.close(true)
        }
    }
    
    @IBAction func closeSelf(_ sender: AnyObject) {
        //close(true)
    }
    func close(_ withAnimation: Bool){
        if (!closing){
            if (withAnimation){
                closing = true
                UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    self.view.frame.origin.x = -1 * self.view.frame.size.width
                    self.view.alpha = 0.0
                    },
                    completion: {result -> Void in
                        self.view.removeFromSuperview()
                        self.removeFromParentViewController()
                        self.closing = false
                })
            } else {
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
            }
        }
        grayView?.removeFromSuperview()
        
    }
    
    func closeMenuAndShowViewController(_ identifier: String){
        close(false)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: identifier)
        self.previousViewController.navigationController?.pushViewController(vc!, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (closing){
            return
        }
        super.touchesBegan(touches, with: event)
        if let touch: UITouch = touches.first!{
            startPoint = touch.location(in: self.view) as CGPoint
            let touchLocation = touch.location(in: self.view) as CGPoint
            
            
            
            self.isDragging = true
            
            if nil != self.closeButton?.frame {
                let f = CGRect(x: self.view.frame.size.width-50, y: 0, width: 100, height: self.view.frame.height)
                if (f.contains(touchLocation)){
                    close(true)
                }
            }
        }
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (closing){
            return
        }
        self.isDragging = false
        if (self.view.frame.origin.x < -1 * (self.view.frame.size.width/99)){
            close(true)
        }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("CANCEL", terminator: "")
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (closing){
            return
        }
        if let touch: UITouch = touches.first{
            let touchLocation = touch.location(in: self.view) as CGPoint
            if (self.isDragging){
                UIView.animate(withDuration: 0.0,
                    delay: 0.0,
                    options: (UIViewAnimationOptions.beginFromCurrentState),
                    animations:  {
                        self.view.frame.origin.x += (touchLocation.x-self.startPoint!.x)
                        self.view.alpha = 0.92 + (self.view.frame.origin.x/self.view.frame.size.width)
                        if (self.view.frame.origin.x > 0){
                            self.view.frame.origin.x = 0
                        }
                    },
                    completion: nil)
                /*
                if let subscriber = CallUtils.subscriber?.view {
                UIView.animateWithDuration(0.0,
                delay: 0.0,
                options: (UIViewAnimationOptions.BeginFromCurrentState|UIViewAnimationOptions.CurveEaseInOut),
                animations:  {subscriber.center = touchLocation},
                completion: nil)
                }*/
            }
        }
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showFeatureFromMenu"){
            //let nav = segue.destinationViewController as! UINavigationController
            //var svc = nav.viewControllers[0] as! FeatureViewController
            //svc.startIndex = self.selectedIndex
        }
    }
    /*
    
    override func shouldAutorotate() -> Bool {
    return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
    return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
    return UIInterfaceOrientation.Portrait
    }
    */
    
}
