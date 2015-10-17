//
//  TypingCellNode.swift
//  Chat
//
//  Created by Petr Pavlik on 01/10/15.
//  Copyright © 2015 Petr Pavlik. All rights reserved.
//

import UIKit

class TypingCellNode: ASCellNode {
    
    private let avatarImageNode = ASImageNode()
    private let bubbleNode = ASDisplayNode()
    private let circleNode0 = ASDisplayNode()
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
        
        avatarImageNode.image = UIImage(named: "689061")
    }
    
    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        return CGSizeMake(constrainedSize.width, 56)
    }
override     
    func layout() {
        avatarImageNode.frame = CGRectMake(8, 10, 36, 36)
        bubbleNode.frame = CGRectMake(51, 10, 100, 36)
    }

}
