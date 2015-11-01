//
//  MessageCell.swift
//  Chat
//
//  Created by Petr Pavlik on 24/10/15.
//  Copyright © 2015 Petr Pavlik. All rights reserved.
//

import UIKit
import Toucan
import AsyncDisplayKit

class MessageCell: ASCellNode {
    
    // MARK: Layout constants
    private let topVerticalPadding: CGFloat = 10.0
    private let bottomVerticalPadding: CGFloat = 10.0
    private let leadingHorizontalPadding: CGFloat = 8.0
    private let trailingHorizontalPadding: CGFloat = 16.0
    private let avatarImageSize = CGSizeMake(36, 36)
    private let avatarBubbleHorizontalDistance: CGFloat = 8.0
    private let bubbleTextMargin: CGFloat = 10
    private let headerTextHeight: CGFloat = 20
    
    private static let bubbleImage: UIImage = {
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(18*2, 18*2), false, UIScreen.mainScreen().scale)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, UIColor.blackColor().CGColor)
        CGContextFillEllipseInRect(context, CGRectMake(0, 0, 18*2, 18*2));
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        image = image.imageWithRenderingMode(.AlwaysTemplate)
        image = image.resizableImageWithCapInsets(UIEdgeInsetsMake(18, 18, 18, 18))
        
        return image
    }()
    
    // MARK: 
    
    let avatarImageNode = ASNetworkImageNode()
    let bubbleNode = ASDisplayNode { () -> UIView! in
        let imageView = UIImageView(image: bubbleImage)
        return imageView
    }
    
    private let headerTextNode = ASTextNode()
    
    var headerText: String? {
        didSet {
            if headerText?.characters.count > 0 {
                headerTextNode.hidden = false
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .Center
                paragraphStyle.lineHeightMultiple = 1.4
                
                headerTextNode.attributedString = NSAttributedString(string: headerText!, attributes: [NSParagraphStyleAttributeName: paragraphStyle, NSForegroundColorAttributeName: UIColor.grayColor()])
            } else {
                headerTextNode.hidden = true
                headerTextNode.attributedString = nil
            }
        }
    }
    
    var incomingMessageColorNormal = UIColor(red:0.941, green:0.941, blue:0.941, alpha: 1)
    var incomingMessageColorSelected = UIColor(red:0.831, green:0.824, blue:0.827, alpha: 1)
    var outgoingMessageColorNormal = UIColor(red:0.004, green:0.518, blue:1.000, alpha: 1)
    var outgoingMessageColorSelected = UIColor(red:0.075, green:0.467, blue:0.976, alpha: 1)
    var avatarPlaceholderColor = UIColor.grayColor()
    
    // MARK:
    
    var isIncommingMessage = true
    
    func requiredBubbleSize(maxWidth: CGFloat) -> CGSize {
        preconditionFailure("This method must be overridden")
    }
    
    // MARK:
    
    override init!() {
        super.init()
        
        selectionStyle = .None
        
        addSubnode(avatarImageNode)
        addSubnode(bubbleNode)
        addSubnode(headerTextNode)
        
        avatarImageNode.placeholderColor = avatarPlaceholderColor
        avatarImageNode.placeholderEnabled = true
        
        
        
        bubbleNode.tintColor = incomingMessageColorNormal
        
        avatarImageNode.imageModificationBlock = { image in
            //return Toucan(image: image).maskWithEllipse().image
            return Toucan(image: image).resize(CGSize(width: 36, height: 36)).maskWithEllipse().image
        }
        
    }
    
    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        
        let headerHeight = headerText?.characters.count > 0 ? headerTextHeight : 0
        
        return CGSizeMake(constrainedSize.width, requiredBubbleSize(maxBubbleWidth(constrainedSize.width)).height + topVerticalPadding + bottomVerticalPadding + headerHeight)
    }
    
    override func layout() {
        
        super.layout()
        
        var bubbleSize = requiredBubbleSize(maxBubbleWidth(frame.width))
        bubbleSize.width = max(40, bubbleSize.width)
        
        let headerHeight = headerText?.characters.count > 0 ? headerTextHeight : 0
        
        if isIncommingMessage == false {
            
            bubbleNode.frame = CGRectMake(bounds.width - (26 + bubbleSize.width), topVerticalPadding + headerHeight, bubbleSize.width, bubbleSize.height)
            
        } else {
            
            avatarImageNode.frame = CGRectMake(leadingHorizontalPadding, topVerticalPadding + headerHeight, avatarImageSize.width, avatarImageSize.height)
            
            bubbleNode.frame = CGRectMake(leadingHorizontalPadding+avatarImageSize.width+avatarBubbleHorizontalDistance, topVerticalPadding + headerHeight, bubbleSize.width, bubbleSize.height)
            
        }
        
        if headerHeight > 0 {
            headerTextNode.frame = CGRectMake(leadingHorizontalPadding, 0, bounds.width-2*leadingHorizontalPadding, headerTextHeight)
        }
    }
    
    private func maxBubbleWidth(cellWidth: CGFloat) -> CGFloat {
        return cellWidth - leadingHorizontalPadding - avatarImageSize.width - avatarBubbleHorizontalDistance - trailingHorizontalPadding
    }


}
