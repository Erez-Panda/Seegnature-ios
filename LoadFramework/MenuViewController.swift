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
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.separatorInset = UIEdgeInsetsZero
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
    
    func getProfileImage(completion: (result: UIImage) -> Void) -> Void{
        if ((profileImageView.image) != nil){
            completion(result: profileImageView.image!)
        } else {
            let defaultUser = NSUserDefaults.standardUserDefaults()
            if let userProfile : AnyObject = defaultUser.objectForKey("userProfile") {
                if let imageFile = userProfile["image_file"] as? NSNumber{
                    getImageFile(imageFile, completion: { (result) -> Void in
                        self.profileImageView.image = result
                        completion(result: result)
                    })
                }
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    func loadCollapseTable(tableView: UITableView, index: Int)-> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("menuCell") as! MenuTableViewCell
        let iconName = self.menuIcons[index]
        cell.leftIconView.image = UIImage(named: iconName)
        cell.leftIconView.hidden = false
        cell.label.text = self.menuItems[index]
        cell.label.textColor = UIColor.blackColor()
        cell.rightButton.hidden = true;
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
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return loadCollapseTable(tableView, index: indexPath.row)
        /*
        if (menuOpen){
        return loadExpendedTable(tableView, index: indexPath.row)
        }else {
        return loadCollapseTable(tableView, index: indexPath.row)
        }
        */
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let index = indexPath.row
        openMenuItem(index)
    }
    
    func openMenuItem(index: Int){
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
            
            let nsObject: AnyObject? = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]
            let version = nsObject as! String
            if let vc = getTopViewController() {
                showAlert(vc, title: "Seegnature", message: "Version: \(version)")
            }
        } else if (index == 1){
            seegnatureManager.logout() {result -> Void in
                AppManager.sharedInstance.cleanUserData()
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("IntroViewController") as! IntroViewController
                self.presentViewController(vc, animated: true, completion: nil)
            }
        } else {
            self.close(true)
        }
    }
    
    @IBAction func closeSelf(sender: AnyObject) {
        //close(true)
    }
    func close(withAnimation: Bool){
        if (!closing){
            if (withAnimation){
                closing = true
                UIView.animateWithDuration(0.5, animations: { () -> Void in
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
    
    func closeMenuAndShowViewController(identifier: String){
        close(false)
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier(identifier)
        self.previousViewController.navigationController?.pushViewController(vc!, animated: true)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (closing){
            return
        }
        super.touchesBegan(touches, withEvent: event)
        if let touch: UITouch = touches.first!{
            startPoint = touch.locationInView(self.view) as CGPoint
            let touchLocation = touch.locationInView(self.view) as CGPoint
            
            
            
            self.isDragging = true
            
            if nil != self.closeButton?.frame {
                let f = CGRectMake(self.view.frame.size.width-50, 0, 100, self.view.frame.height)
                if (CGRectContainsPoint(f, touchLocation)){
                    close(true)
                }
            }
        }
        
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (closing){
            return
        }
        self.isDragging = false
        if (self.view.frame.origin.x < -1 * (self.view.frame.size.width/99)){
            close(true)
        }
    }
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        print("CANCEL")
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if (closing){
            return
        }
        if let touch: UITouch = touches.first{
            let touchLocation = touch.locationInView(self.view) as CGPoint
            if (self.isDragging){
                UIView.animateWithDuration(0.0,
                    delay: 0.0,
                    options: ([UIViewAnimationOptions.BeginFromCurrentState, UIViewAnimationOptions.CurveEaseInOut]),
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
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
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
