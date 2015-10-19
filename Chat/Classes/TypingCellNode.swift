//
//  TypingCellNode.swift
//  Chat
//
//  Created by Petr Pavlik on 01/10/15.
//  Copyright © 2015 Petr Pavlik. All rights reserved.
//

import UIKit

class TypingCellNode: ASCellNode {
    
    private let avatarImageNode = ASNetworkImageNode()
    private let bubbleNode = ASDisplayNode()
    
    private let circleNode0 = ASDisplayNode { () -> UIView! in
        let view = UIView()
        view.layer.cornerRadius = 6
        view.backgroundColor = .blackColor()
        
        view.alpha = 1.0
        UIView.animateWithDuration(1, delay: 0, options: [.Autoreverse, .Repeat], animations: { () -> Void in
            view.alpha = 0.5
        }, completion: nil)
        
        return view
    }
    
    private let circleNode1 = ASDisplayNode()
    private let circleNode2 = ASDisplayNode()
    
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
        
        //circleNode0.backgroundColor = .blackColor()
        circleNode1.backgroundColor = .blackColor()
        circleNode2.backgroundColor = .blackColor()
        
        //circleNode0.layer.cornerRadius = 6
        circleNode1.layer.cornerRadius = 6
        circleNode2.layer.cornerRadius = 6
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
