//
//  TypingCellNode.swift
//  Chat
//
//  Created by Petr Pavlik on 01/10/15.
//  Copyright © 2015 Petr Pavlik. All rights reserved.
//

import UIKit
import AsyncDisplayKit

public class TypingMessageCell: MessageCell {
    
    func startAnimating() {
        
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            self?.circleNode0.startAnimating()
            self?.circleNode1.startAnimating()
            self?.circleNode2.startAnimating()
        }
    }
    
    static private let dotImage: UIImage = {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(12, 12), false, UIScreen.mainScreen().scale)
        CGContextSetRGBFillColor(UIGraphicsGetCurrentContext(), 0, 0, 0, 1.0)
        CGContextFillEllipseInRect (UIGraphicsGetCurrentContext(), CGRectMake(0, 0, 12, 12));
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }()
    
    private class CircleNode: ASImageNode {
        
        func startAnimating() {
            view.alpha = 1
            UIView.animateWithDuration(0.5, delay: animationDelay, options: [.Autoreverse, .Repeat], animations: { () -> Void in
                self.view.alpha = 0.5
            }, completion: nil)
        }
        
        private let animationDelay: NSTimeInterval
        
        init(animationDelay: NSTimeInterval) {
            
            self.animationDelay = animationDelay
            
            super.init()
            
            image = dotImage
        }
    }
    
    private let circleNode0 = CircleNode(animationDelay: 0)
    private let circleNode1 = CircleNode(animationDelay: 0.2)
    private let circleNode2 = CircleNode(animationDelay: 0.4)
    
    public override init!() {
        super.init()
        
        addSubnode(circleNode0)
        addSubnode(circleNode1)
        addSubnode(circleNode2)
    }
    
    public override func layout() {
        super.layout()
        
        circleNode0.frame = CGRectMake(51+10, (bounds.height-12)/2, 12, 12)
        circleNode1.frame = CGRectMake(51+10+12+10, (bounds.height-12)/2, 12, 12)
        circleNode2.frame = CGRectMake(51+10+12+10+12+10, (bounds.height-12)/2, 12, 12)
    }
    
    func layoutSpecForMessageBubble() -> ASLayoutSpec! {
        let spec = ASStaticLayoutSpec()
        //spec.
        return spec
    }
}
