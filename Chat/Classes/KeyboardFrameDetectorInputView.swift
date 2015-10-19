//
//  KeyboardFrameDetectorInputView.swift
//  Chat
//
//  Created by Petr Pavlik on 18/10/15.
//  Copyright © 2015 Petr Pavlik. All rights reserved.
//

import UIKit

class KeyboardFrameDetectorInputView: UIInputView {
    
    var keyboardFrameChangedBlock: ((frame: CGRect) -> Void)?
    
    // Has to be strong to prevent KVO crash.
    private var keyboardView: UIView?
    
    deinit {
        keyboardView?.removeObserver(self, forKeyPath: "center")
    }

    override func willMoveToSuperview(newSuperview: UIView?) {
        
        if keyboardView != nil {
            keyboardView!.removeObserver(self, forKeyPath: "center")
            keyboardView = nil
        }
        
        let keyboardWindow = UIApplication.sharedApplication().windows.filter { (element) -> Bool in
            element.isKindOfClass(NSClassFromString("UIRemoteKeyboardWindow")!)
        }.first
        
        if let keyboardWindow = keyboardWindow {
            
            for subview in keyboardWindow.subviews {
                for hostView in subview.subviews {
                    if hostView.isMemberOfClass(NSClassFromString("UIInputSetHostView")!) {
                        keyboardView = hostView
                    }
                }
            }
            
            keyboardView!.addObserver(self, forKeyPath: "center", options: [.New], context: nil)
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if object as? UIView == keyboardView {
            keyboardFrameChangedBlock?(frame: keyboardView!.frame)
        }
    }
    
}
