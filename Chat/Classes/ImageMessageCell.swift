//
//  ImageMessageCell.swift
//  Chat
//
//  Created by Petr Pavlik on 25/10/15.
//  Copyright © 2015 Petr Pavlik. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Toucan

class ImageMessageCell: MessageCell, ASNetworkImageNodeDelegate {
    
    private let imageNode = ASNetworkImageNode()
    
    init(imageURL: NSURL, isIncomming: Bool) {
        super.init()
        
        self.isIncommingMessage = isIncomming
        
        addSubnode(imageNode)
        
        imageNode.delegate = self
        
        imageNode.imageModificationBlock = { [unowned self] (image) in
            var toucanImage = Toucan(image: image).resize(self.requiredBubbleSize(256))
            toucanImage = toucanImage.maskWithPath(path: UIBezierPath(roundedRect: CGRectMake(0, 0, toucanImage.image.size.width, toucanImage.image.size.height), cornerRadius: 18))
            return toucanImage.image
        }
        
        imageNode.setURL(imageURL, resetToDefault: true)
        
        isIncommingMessage = isIncomming
        
        if isIncomming == true {
            bubbleNode.tintColor = incomingMessageColorNormal
        } else {
            bubbleNode.tintColor = outgoingMessageColorNormal
        }
    }
    
    override func layout() {
        super.layout()
        imageNode.frame = bubbleNode.frame
    }
    
    override func requiredBubbleSize(maxWidth: CGFloat) -> CGSize {
        
        return CGSizeMake(maxWidth, (maxWidth/4)*3)
    }

    func imageNode(imageNode: ASNetworkImageNode!, didLoadImage image: UIImage!) {
        
    }
    
}
