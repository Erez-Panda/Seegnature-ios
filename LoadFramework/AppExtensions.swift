//
//  AppExtensions.swift
//  Seegnature
//
//  Created by Moshe Krush on 10/03/16.
//  Copyright © 2016 Moshe Krush. All rights reserved.
//

import Foundation
import UIKit
import SeegnatureSDK

extension UIView {
    func borderView(borderWidth: CGFloat, borderColor: UIColor, borderRadius: CGFloat){
        self.layer.borderWidth = borderWidth
        self.layer.cornerRadius = borderRadius
        self.layer.cornerRadius = borderRadius
        self.clipsToBounds = true
        self.layer.borderColor = borderColor.CGColor
    }
    
    func roundView(borderWidth: CGFloat, borderColor: UIColor){
        let frame =  self.frame;
        self.layer.cornerRadius = frame.size.height / 2
        self.clipsToBounds = true
        self.layer.borderWidth = borderWidth;
        self.layer.borderColor = borderColor.CGColor
    }
}

extension NSDate {
    func convertToServerString() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = NSDateFormatter.dateFormatFromTemplate("yyyy-MM-dd'T'HH:mm:ss", options: 0, locale: nil)
        let stringDate = dateFormatter.stringFromDate(self)
        return stringDate
        
    }
}

extension NSMutableData {
    
    /// Append string to NSMutableData
    ///
    /// Rather than littering my code with calls to `dataUsingEncoding` to convert strings to NSData, and then add that data to the NSMutableData, this wraps it in a nice convenient little extension to NSMutableData. This converts using UTF-8.
    ///
    /// - parameter string:       The string to be added to the `NSMutableData`.
    
    func appendString(string: String) {
        let data = string.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        appendData(data!)
    }
}

extension NSURL {
    func getKeyVals() -> Dictionary<String, String>? {
        var results = [String:String]()
        let keyValues = self.query?.componentsSeparatedByString("&")
        if keyValues?.count > 0 {
            for pair in keyValues! {
                let kv = pair.componentsSeparatedByString("=")
                if kv.count > 1 {
                    results.updateValue(kv[1], forKey: kv[0])
                }
            }
            
        }
        return results
    }
}


// MARK: public methods

func getAttrText(string:String, color: UIColor, size: CGFloat) -> NSMutableAttributedString{
    return getAttrText(string, color: color, size: size, fontName: "OpenSans")
}

func getAttrText(string:String, color: UIColor, size: CGFloat, fontName:String) -> NSMutableAttributedString{
    return getAttrText(string, color: color, size: size, fontName: fontName, addShadow: false)
}

func getAttrText(string:String, color: UIColor, size: CGFloat, fontName:String, addShadow: Bool) -> NSMutableAttributedString{
    let str = NSMutableAttributedString(string: string)
    str.addAttribute(NSForegroundColorAttributeName,
        value: color,
        range: NSMakeRange(0,string.characters.count))
    str.addAttributes([NSFontAttributeName:UIFont(name: fontName, size: size )!], range:  NSMakeRange(0,string.characters.count) )
    if (addShadow){
        let shadow = NSShadow()
        shadow.shadowBlurRadius = 5;
        shadow.shadowColor = UIColor.whiteColor()
        shadow.shadowOffset = CGSizeMake(0, 0)
        str.addAttributes([NSShadowAttributeName:shadow], range:  NSMakeRange(0,string.characters.count))
    }
    return str
}

func uicolorFromHex(rgbValue:UInt32)->UIColor{
    let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
    let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
    let blue = CGFloat(rgbValue & 0xFF)/256.0
    return UIColor(red:red, green:green, blue:blue, alpha:1.0)
}

func showAlert(currentVC: UIViewController, title: String = "Error", message: String) {
    if let topVC = getTopViewController() {
        if topVC is UIAlertController {
            return
        } else {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .Default) { (action:UIAlertAction!) in
                print("OK button pressed");
            }
            
            alertController.addAction(OKAction)
            currentVC.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}

func getTopViewController() -> UIViewController? {
    if var topController = UIApplication.sharedApplication().keyWindow?.rootViewController {
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        
        return topController
        
    } else {
        return nil
    }
}

func getImageFile(id: NSNumber, completion: (result: UIImage) -> Void) -> Void{
    let seegnatureManager = SeegnatureActions()
    seegnatureManager.getFileFromURL(id, completion: { (result) -> Void in
        if let url = NSURL(string: result as String){
            if let data = NSData(contentsOfURL: url){
                dispatch_async(dispatch_get_main_queue()){
                    let image = UIImage(data: data)
                    completion(result: image!)
                }
            }
        }
    })
}

func showSpinner(text: String) {
    dispatch_async(dispatch_get_main_queue()){
        SwiftSpinner.show(text)
    }
}

func hideSpinner() {
    dispatch_async(dispatch_get_main_queue()){
        SwiftSpinner.hide()
    }
}

func setBordersForTextField(view: UIView, borderWidth: CGFloat) {
    
    // top border
    let topBorder = CALayer()
    topBorder.frame = CGRectMake(0.0, 0.0, view.frame.size.width, borderWidth)
    topBorder.backgroundColor = uicolorFromHex(0x67CA94).CGColor
    view.layer.addSublayer(topBorder)
    
}

func leftBorderView(view: UIView, borderWidth: CGFloat, borderColor: UIColor) -> CALayer {
    let leftBorder = CALayer()
    leftBorder.frame = CGRectMake(0.0, 0.0, borderWidth, view.frame.size.height);
    leftBorder.backgroundColor = borderColor.CGColor
    view.layer.addSublayer(leftBorder)
    return leftBorder
}

func rightBorderView(view: UIView, borderWidth: CGFloat, borderColor: UIColor) -> CALayer {
    let leftBorder = CALayer()
    leftBorder.frame = CGRectMake(view.frame.size.width-borderWidth, 0.0, borderWidth, view.frame.size.height);
    leftBorder.backgroundColor = borderColor.CGColor
    view.layer.addSublayer(leftBorder)
    return leftBorder
}

func bottomBorderView(view: UIView, borderWidth: CGFloat, borderColor: UIColor, offset: CGFloat) -> CALayer{
    let bottomBorder = CALayer()
    bottomBorder.frame = CGRectMake(0.0, view.frame.size.height + offset, view.frame.size.width, borderWidth)
    bottomBorder.backgroundColor = borderColor.CGColor
    view.layer.addSublayer(bottomBorder)
    return bottomBorder
}

func topBorderView(view: UIView, borderWidth: CGFloat, borderColor: UIColor, offset: CGFloat) -> CALayer{
    let topBorder = CALayer()
    topBorder.frame = CGRectMake(0.0, 0.0 + offset, view.frame.size.width, borderWidth)
    topBorder.backgroundColor = borderColor.CGColor
    view.layer.addSublayer(topBorder)
    return topBorder
}