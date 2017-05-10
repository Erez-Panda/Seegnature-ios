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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


extension UIView {
    func borderView(_ borderWidth: CGFloat, borderColor: UIColor, borderRadius: CGFloat){
        self.layer.borderWidth = borderWidth
        self.layer.cornerRadius = borderRadius
        self.layer.cornerRadius = borderRadius
        self.clipsToBounds = true
        self.layer.borderColor = borderColor.cgColor
    }
    
    func roundView(_ borderWidth: CGFloat, borderColor: UIColor){
        let frame =  self.frame;
        self.layer.cornerRadius = frame.size.height / 2
        self.clipsToBounds = true
        self.layer.borderWidth = borderWidth;
        self.layer.borderColor = borderColor.cgColor
    }
}

extension Date {
    func convertToServerString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyy-MM-dd'T'HH:mm:ss", options: 0, locale: nil)
        let stringDate = dateFormatter.string(from: self)
        return stringDate
        
    }
}

extension NSMutableData {
    
    /// Append string to NSMutableData
    ///
    /// Rather than littering my code with calls to `dataUsingEncoding` to convert strings to NSData, and then add that data to the NSMutableData, this wraps it in a nice convenient little extension to NSMutableData. This converts using UTF-8.
    ///
    /// - parameter string:       The string to be added to the `NSMutableData`.
    
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}

extension URL {
    func getKeyVals() -> Dictionary<String, String>? {
        var results = [String:String]()
        let keyValues = self.query?.components(separatedBy: "&")
        if keyValues?.count > 0 {
            for pair in keyValues! {
                let kv = pair.components(separatedBy: "=")
                if kv.count > 1 {
                    results.updateValue(kv[1], forKey: kv[0])
                }
            }
            
        }
        return results
    }
}


// MARK: public methods

func getAttrText(_ string:String, color: UIColor, size: CGFloat) -> NSMutableAttributedString{
    return getAttrText(string, color: color, size: size, fontName: "OpenSans")
}

func getAttrText(_ string:String, color: UIColor, size: CGFloat, fontName:String) -> NSMutableAttributedString{
    return getAttrText(string, color: color, size: size, fontName: fontName, addShadow: false)
}

func getAttrText(_ string:String, color: UIColor, size: CGFloat, fontName:String, addShadow: Bool) -> NSMutableAttributedString{
    let str = NSMutableAttributedString(string: string)
    str.addAttribute(NSForegroundColorAttributeName,
        value: color,
        range: NSMakeRange(0,string.characters.count))
    str.addAttributes([NSFontAttributeName:UIFont(name: fontName, size: size )!], range:  NSMakeRange(0,string.characters.count) )
    if (addShadow){
        let shadow = NSShadow()
        shadow.shadowBlurRadius = 5;
        shadow.shadowColor = UIColor.white
        shadow.shadowOffset = CGSize(width: 0, height: 0)
        str.addAttributes([NSShadowAttributeName:shadow], range:  NSMakeRange(0,string.characters.count))
    }
    return str
}

func uicolorFromHex(_ rgbValue:UInt32)->UIColor{
    let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
    let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
    let blue = CGFloat(rgbValue & 0xFF)/256.0
    return UIColor(red:red, green:green, blue:blue, alpha:1.0)
}

func showAlert(_ currentVC: UIViewController, title: String = "Error", message: String) {
    if let topVC = getTopViewController() {
        if topVC is UIAlertController {
            return
        } else {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                print("OK button pressed", terminator: "");
            }
            
            alertController.addAction(OKAction)
            currentVC.present(alertController, animated: true, completion: nil)
        }
    }
}

func getTopViewController() -> UIViewController? {
    if var topController = UIApplication.shared.keyWindow?.rootViewController {
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        
        return topController
        
    } else {
        return nil
    }
}

func getImageFile(_ id: NSNumber, completion: @escaping (_ result: UIImage) -> Void) -> Void{
    let seegnatureManager = SeegnatureActions()
    seegnatureManager.getFileFromURL(id, completion: { (result) -> Void in
        if let url = URL(string: result as String){
            if let data = try? Data(contentsOf: url){
                DispatchQueue.main.async{
                    let image = UIImage(data: data)
                    completion(image!)
                }
            }
        }
    })
}

func showSpinner(_ text: String) {
    DispatchQueue.main.async{
        SwiftSpinner.show(text)
    }
}

func hideSpinner() {
    DispatchQueue.main.async{
        SwiftSpinner.hide()
    }
}

func setBordersForTextField(_ view: UIView, borderWidth: CGFloat) {
    
    // top border
    let topBorder = CALayer()
    topBorder.frame = CGRect(x: 0.0, y: 0.0, width: view.frame.size.width, height: borderWidth)
    topBorder.backgroundColor = uicolorFromHex(0x67CA94).cgColor
    view.layer.addSublayer(topBorder)
    
}

func leftBorderView(_ view: UIView, borderWidth: CGFloat, borderColor: UIColor) -> CALayer {
    let leftBorder = CALayer()
    leftBorder.frame = CGRect(x: 0.0, y: 0.0, width: borderWidth, height: view.frame.size.height);
    leftBorder.backgroundColor = borderColor.cgColor
    view.layer.addSublayer(leftBorder)
    return leftBorder
}

func rightBorderView(_ view: UIView, borderWidth: CGFloat, borderColor: UIColor) -> CALayer {
    let leftBorder = CALayer()
    leftBorder.frame = CGRect(x: view.frame.size.width-borderWidth, y: 0.0, width: borderWidth, height: view.frame.size.height);
    leftBorder.backgroundColor = borderColor.cgColor
    view.layer.addSublayer(leftBorder)
    return leftBorder
}

func bottomBorderView(_ view: UIView, borderWidth: CGFloat, borderColor: UIColor, offset: CGFloat) -> CALayer{
    let bottomBorder = CALayer()
    bottomBorder.frame = CGRect(x: 0.0, y: view.frame.size.height + offset, width: view.frame.size.width, height: borderWidth)
    bottomBorder.backgroundColor = borderColor.cgColor
    view.layer.addSublayer(bottomBorder)
    return bottomBorder
}

func topBorderView(_ view: UIView, borderWidth: CGFloat, borderColor: UIColor, offset: CGFloat) -> CALayer{
    let topBorder = CALayer()
    topBorder.frame = CGRect(x: 0.0, y: 0.0 + offset, width: view.frame.size.width, height: borderWidth)
    topBorder.backgroundColor = borderColor.cgColor
    view.layer.addSublayer(topBorder)
    return topBorder
}
