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

public class ImageMessageCell: MessageCell, ASNetworkImageNodeDelegate {
    
    private let imageNode = ASNetworkImageNode()
    
    //FIXME: This is probably called on multiple threads.
    private var requiredImageSize = CGSizeZero
    
    public init(imageURL: NSURL, isIncomming: Bool) {
        super.init()
        
        self.isIncomingMessage = isIncomming
        
        addSubnode(imageNode)
        
        imageNode.delegate = self
        
        imageNode.imageModificationBlock = { (image) in
            var toucanImage = Toucan(image: image).resize(CGSizeMake(200, 200/4*3))
            toucanImage = toucanImage.maskWithPath(path: UIBezierPath(roundedRect: CGRectMake(0, 0, toucanImage.image.size.width, toucanImage.image.size.height), cornerRadius: 18))
            return toucanImage.image
        }
        
        imageNode.setURL(imageURL, resetToDefault: true)
        
        isIncomingMessage = isIncomming
        
        if isIncomming == true {
            bubbleNode.tintColor = incomingMessageColorNormal
        } else {
            bubbleNode.tintColor = outgoingMessageColorNormal
        }
    }
    
    override func layoutSpecForBubbneNode(bubbleNode: ASDisplayNode) -> ASLayoutSpec {
        
        imageNode.sizeRange = ASRelativeSizeRangeMakeWithExactCGSize(CGSizeMake(200, 200/4*3))
        let imageSizeSpec = ASStaticLayoutSpec(children: [imageNode])
        return ASBackgroundLayoutSpec(child: imageSizeSpec, background: bubbleNode)
    }
    
    /*func layoutSpecForMessageBubble() -> ASLayoutSpec {
        
        let sizeLayout = ASStackLayoutSpec(direction: .Horizontal, spacing: 0, justifyContent: .Start, alignItems: .Start, children: [bubbleNode])
        
        sizeLayout.sizeRange = ASRelativeSizeRangeMake(
            ASRelativeSizeMake(ASRelativeDimensionMakeWithPoints(100), ASRelativeDimensionMakeWithPoints(0)),
            ASRelativeSizeMake(ASRelativeDimensionMakeWithPoints(100), ASRelativeDimensionMakeWithPoints(100))
        )
        
        let aspectLayout = ASRatioLayoutSpec(ratio: 4/3, child: bubbleNode)
        
        return ASStaticLayoutSpec(children: [sizeLayout, aspectLayout])
    }*/

    public func imageNode(imageNode: ASNetworkImageNode!, didLoadImage image: UIImage!) {
        
    }
    
}
