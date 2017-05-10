//
//  UIEventRegister.swift
//  Panda4doctor
//
//  Created by Erez on 1/28/15.
//  Copyright (c) 2015 Erez. All rights reserved.
//

import UIKit

struct UIEventRegister {
    
    static func gestureRecognizer(_ sender: UIViewController, rightAction: Selector?, leftAction: Selector?, upAction: Selector?, downAction: Selector?) -> Void{
        if rightAction != nil {
            let swipeRight = UISwipeGestureRecognizer(target: sender, action: rightAction)
            swipeRight.direction = UISwipeGestureRecognizerDirection.right
            swipeRight.cancelsTouchesInView = false
            sender.view.addGestureRecognizer(swipeRight)
        }
        if leftAction != nil {
            let swipeLeft = UISwipeGestureRecognizer(target: sender, action: leftAction)
            swipeLeft.direction = UISwipeGestureRecognizerDirection.left
            swipeLeft.cancelsTouchesInView = false
            sender.view.addGestureRecognizer(swipeLeft)
        }
        if upAction != nil {
            let swipeUp = UISwipeGestureRecognizer(target: sender, action: upAction)
            swipeUp.direction = UISwipeGestureRecognizerDirection.up
            swipeUp.cancelsTouchesInView = false
            sender.view.addGestureRecognizer(swipeUp)
        }
        if downAction != nil {
            let swipeDown = UISwipeGestureRecognizer(target: sender, action: downAction)
            swipeDown.direction = UISwipeGestureRecognizerDirection.down
            swipeDown.cancelsTouchesInView = false
            sender.view.addGestureRecognizer(swipeDown)
        }
        
    }
    
    static func tapRecognizer(_ sender: UIViewController, action: Selector){
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(target: sender, action: action)
        tap.cancelsTouchesInView = false
        sender.view.addGestureRecognizer(tap)
    }
}
