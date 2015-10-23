//
//  TypingCellNode.swift
//  Chat
//
//  Created by Petr Pavlik on 01/10/15.
//  Copyright © 2015 Petr Pavlik. All rights reserved.
//

import UIKit

class TypingCellNode: ASCellNode {
    
    func startAnimating() {
        circleNode0.startAnimating()
        circleNode1.startAnimating()
        circleNode2.startAnimating()
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
            
        }
        
        private let animationDelay: NSTimeInterval
        
        init(animationDelay: NSTimeInterval) {
            
            self.animationDelay = animationDelay
            
            super.init()
            
            image = dotImage
        }
        
        private override func displayDidFinish() {
            super.displayDidFinish()
            
            dispatch_async(dispatch_get_main_queue()) { [weak self] in
                if let strongSelf = self {
                    UIView.animateWithDuration(0.5, delay: strongSelf.animationDelay, options: [.Autoreverse, .Repeat], animations: { () -> Void in
                        self?.view.alpha = 0.5
                        }, completion: nil)
                }
            }
        }
    }
    
    private let avatarImageNode = ASNetworkImageNode()
    private let bubbleNode = ASDisplayNode()
    
    private let circleNode0 = CircleNode(animationDelay: 0)
    private let circleNode1 = CircleNode(animationDelay: 0.2)
    private let circleNode2 = CircleNode(animationDelay: 0.4)
    
    override init!() {
        super.init()
        
        selectionStyle = .None
        
        addSubnode(avatarImageNode)
        addSubnode(bubbleNode)
        
        avatarImageNode.layer.masksToBounds = true
        avatarImageNode.layer.cornerRadius = 18
        
        bubbleNode.layer.masksToBounds = true
        bubbleNode.layer.cornerRadius = 18
        
        bubbleNode.backgroundColor = UIColor(red:0.941, green:0.941, blue:0.941, alpha: 1)
        
        addSubnode(circleNode0)
        addSubnode(circleNode1)
        addSubnode(circleNode2)
    }
    
    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        return CGSizeMake(constrainedSize.width, 56)
    }
    
    override func layout() {
        
        avatarImageNode.frame = CGRectMake(8, 10, 36, 36)
        bubbleNode.frame = CGRectMake(51, 10, 10*4+3*12, 36)
        
        circleNode0.frame = CGRectMake(51+10, (bounds.height-12)/2, 12, 12)
        circleNode1.frame = CGRectMake(51+10+12+10, (bounds.height-12)/2, 12, 12)
        circleNode2.frame = CGRectMake(51+10+12+10+12+10, (bounds.height-12)/2, 12, 12)
    }
    
    func configure(avatarURL: NSURL) {
        avatarImageNode.setURL(avatarURL, resetToDefault: false)
    }
}
