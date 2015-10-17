//
//  ChatCellNode.swift
//  Chat
//
//  Created by Petr Pavlik on 27/09/15.
//  Copyright © 2015 Petr Pavlik. All rights reserved.
//

import UIKit

class ChatCellNode: ASCellNode, ASTextNodeDelegate {
    
    private class VideoButtonNode: ASNetworkImageNode {

        enum State {
            case Idle
            case Loading
        }
        
        var state = State.Idle {
            didSet {
                
            }
        }
        
        private let playImageNode = ASImageNode()
        private let loadingNode = ASImageNode { () -> UIView! in
            return UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        }
        
        override init!() {
            super.init()
            
            addSubnode(loadingNode)
            addSubnode(playImageNode)
        }
    }
    
    func configureIncommingMessage(messageText: String, avatarURL: NSURL) {
        
        outgoingMessage = false
        
        let attributes = [NSFontAttributeName: UIFont.systemFontOfSize(17), NSForegroundColorAttributeName: UIColor.blackColor()]
        let attributedString = NSAttributedString(string: messageText, attributes: attributes).mutableCopy() as! NSMutableAttributedString
        
        avatarImageNode.hidden = false
        avatarImageNode.setURL(avatarURL, resetToDefault: false)
        
        let types: NSTextCheckingType = [.Link, .PhoneNumber]
        let detector = try? NSDataDetector(types: types.rawValue)
        detector?.enumerateMatchesInString(messageText, options: [], range: NSMakeRange(0, (messageText as NSString).length)) { (result, flags, _) in
            if let URL = result?.URL {
                attributedString.addAttribute(NSLinkAttributeName, value: URL, range: result!.range)
            }
        }
        
        messageTextNode.attributedString = attributedString
        
        bubbleNode.backgroundColor = UIColor(red:0.941, green:0.941, blue:0.941, alpha: 1)
        
        invalidateCalculatedSize()
    }
    
    func configureOutgoingMessage(messageText: String) {
        avatarImageNode.hidden = true
        outgoingMessage = true
        
        let attributes = [NSFontAttributeName: UIFont.systemFontOfSize(17), NSForegroundColorAttributeName: UIColor.whiteColor()]
        let attributedString = NSAttributedString(string: messageText, attributes: attributes).mutableCopy() as! NSMutableAttributedString
        
        let types: NSTextCheckingType = [.Link, .PhoneNumber]
        let detector = try? NSDataDetector(types: types.rawValue)
        detector?.enumerateMatchesInString(messageText, options: [], range: NSMakeRange(0, (messageText as NSString).length)) { (result, flags, _) in
            if let URL = result?.URL {
                attributedString.addAttribute(NSLinkAttributeName, value: URL, range: result!.range)
            }
        }
        
        messageTextNode.attributedString = attributedString
        
        bubbleNode.backgroundColor = UIColor(red:0.004, green:0.518, blue:1.000, alpha: 1)
        
        invalidateCalculatedSize()
    }
    
    var messageDate: NSDate?
    
    private let avatarImageNode = ASNetworkImageNode()
    private let bubbleNode = ASDisplayNode()
    private let messageTextNode = ASTextNode()
    private let dateTextNode = ASTextNode()
    
    private var outgoingMessage = false
    
    // MARK: Layout constants
    private let topVerticalPadding: CGFloat = 10.0
    private let bottomVerticalPadding: CGFloat = 10.0
    private let leftHorizontalPadding: CGFloat = 8.0
    private let avatarImageSize = CGSizeMake(36, 36)
    private let avatarBubbleHorizontalDistance: CGFloat = 8.0
    private let bubbleTextMargin: CGFloat = 10
    
    
    override init!() {
        super.init()
        
        selectionStyle = .None
        
        addSubnode(avatarImageNode)
        addSubnode(bubbleNode)
        addSubnode(messageTextNode)
        addSubnode(dateTextNode)
        
        avatarImageNode.layer.masksToBounds = true
        avatarImageNode.layer.cornerRadius = 18
        
        bubbleNode.layer.masksToBounds = true
        bubbleNode.layer.cornerRadius = 18
        
        messageTextNode.delegate = self
        messageTextNode.userInteractionEnabled = true
        
        dateTextNode.attributedString = NSAttributedString(string: "THU 18:19", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(12), NSForegroundColorAttributeName: UIColor.grayColor()])
        
        //avatarImageNode.image = UIImage(named: "689061")
        avatarImageNode.backgroundColor = UIColor.grayColor()
    }
    
    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        
        return CGSizeMake(constrainedSize.width, requiredBubbleSize().height + topVerticalPadding + bottomVerticalPadding)
    }
    
    override func layout() {
        
        var bubbleSize = requiredBubbleSize()
        bubbleSize.width = max(40, bubbleSize.width)
        
        if outgoingMessage == true {
            
            bubbleNode.frame = CGRectMake(bounds.width - (26 + bubbleSize.width), topVerticalPadding, bubbleSize.width, bubbleSize.height)
            
            messageTextNode.frame = CGRectInset(bubbleNode.frame, bubbleTextMargin, bubbleTextMargin)
            
        } else {
            
            avatarImageNode.frame = CGRectMake(leftHorizontalPadding, topVerticalPadding, avatarImageSize.width, avatarImageSize.height)
            
            bubbleNode.frame = CGRectMake(leftHorizontalPadding+avatarImageSize.width+avatarBubbleHorizontalDistance, topVerticalPadding, bubbleSize.width, bubbleSize.height)
            
            messageTextNode.frame = CGRectInset(bubbleNode.frame, bubbleTextMargin, bubbleTextMargin)
            
        }
        
        /*let requiredDateTextSize = dateTextNode.attributedString.boundingRectWithSize(CGSizeMake(240, 1000), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil)
        
        dateTextNode.frame = CGRectMake((bounds.width - requiredDateTextSize.width)/2, 0, 30, 12)*/
    }
    
    private func requiredBubbleSize() -> CGSize {
        var size = messageTextNode.attributedString.boundingRectWithSize(CGSizeMake(240, 1000), options: [NSStringDrawingOptions.UsesLineFragmentOrigin, NSStringDrawingOptions.UsesFontLeading], context: nil).size
        size.width += 2*bubbleTextMargin
        size.height += 2*bubbleTextMargin
        return size
    }
    
    func textNode(textNode: ASTextNode!, shouldHighlightLinkAttribute attribute: String!, value: AnyObject!, atPoint point: CGPoint) -> Bool {
        return true
    }
    
    func textNode(textNode: ASTextNode!, shouldLongPressLinkAttribute attribute: String!, value: AnyObject!, atPoint point: CGPoint) -> Bool {
        return true
    }
    
    func textNode(textNode: ASTextNode!, tappedLinkAttribute attribute: String!, value: AnyObject!, atPoint point: CGPoint, textRange: NSRange) {
        UIApplication.sharedApplication().openURL(value as! NSURL)
    }

}
