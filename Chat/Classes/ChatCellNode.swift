//
//  ChatCellNode.swift
//  Chat
//
//  Created by Petr Pavlik on 27/09/15.
//  Copyright © 2015 Petr Pavlik. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import Toucan

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
                attributedString.addAttribute("aaa", value: URL, range: result!.range)
                //attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor(), range: result!.range)
                attributedString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.StyleSingle.rawValue, range: result!.range)
            }
        }
        
        messageTextNode.attributedString = attributedString
        
        bubbleNode.tintColor = incomingMessageColorNormal
        
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
                attributedString.addAttribute("aaa", value: URL, range: result!.range)
            }
        }
        
        messageTextNode.attributedString = attributedString
        
        bubbleNode.tintColor = outgoingMessageColorNormal
        bubbleNode.tintColorDidChange()
        
        invalidateCalculatedSize()
    }
    
    var messageDate: NSDate?
    
    private let avatarImageNode = ASNetworkImageNode()
    private let bubbleNode = ASDisplayNode { () -> UIView! in
        let imageView = UIImageView(image: bubbleImage)
        //imageView.contentMode = UIViewContentMode.TopLeft
        return imageView
    }
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
    
    private let incomingMessageColorNormal = UIColor(red:0.941, green:0.941, blue:0.941, alpha: 1)
    private let incomingMessageColorSelected = UIColor(red:0.831, green:0.824, blue:0.827, alpha: 1)
    private let outgoingMessageColorNormal = UIColor(red:0.004, green:0.518, blue:1.000, alpha: 1)
    private let outgoingMessageColorSelected = UIColor(red:0.075, green:0.467, blue:0.976, alpha: 1)
    
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
    
    override init!() {
        super.init()
        
        selectionStyle = .None
        
        addSubnode(avatarImageNode)
        addSubnode(bubbleNode)
        addSubnode(messageTextNode)
        addSubnode(dateTextNode)
        
        avatarImageNode.imageModificationBlock = { image in
            //return Toucan(image: image).maskWithEllipse().image
            return Toucan(image: image).maskWithEllipse(borderWidth: 2, borderColor: UIColor.yellowColor()).image
        }
        
        messageTextNode.passthroughNonlinkTouches = true
        
        //avatarImageNode.layer.masksToBounds = true
        //avatarImageNode.layer.cornerRadius = 18
        
        //bubbleNode.layer.masksToBounds = true
        //bubbleNode.layer.cornerRadius = 18
        
        messageTextNode.delegate = self
        messageTextNode.userInteractionEnabled = true
        messageTextNode.linkAttributeNames = ["aaa"]
        
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
    
    override func didLoad() {
        super.didLoad()
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: Selector("bubbleLongPressed:"))
        view.addGestureRecognizer(longPressRecognizer)
    }
    
    func bubbleLongPressed(recognizer: UITapGestureRecognizer) {
        if recognizer.state == UIGestureRecognizerState.Began {
            
            let touchLocation = recognizer.locationInView(view)
            if CGRectContainsPoint(bubbleNode.frame, touchLocation) {
                
                view.becomeFirstResponder()
                
                let menuController = UIMenuController.sharedMenuController()
                menuController.menuItems = [UIMenuItem(title: "Copy", action: Selector("copySelected"))]
                menuController.setTargetRect(CGRectMake(touchLocation.x, touchLocation.y-10, 0, 0), inView: view)
                menuController.setMenuVisible(true, animated:true)
            }
        }
    }
    
    override func touchesBegan(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        super.touchesBegan(touches, withEvent: event)
        
        setBubbleBackgroundForSelectedState()
        
        if UIMenuController.sharedMenuController().menuVisible == true {
           UIMenuController.sharedMenuController().setMenuVisible(false, animated: true)
            setBubbleBackgroundForNormalState()
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        super.touchesEnded(touches, withEvent: event)
        
        if UIMenuController.sharedMenuController().menuVisible == false {
            setBubbleBackgroundForNormalState()
        }
    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        super.touchesCancelled(touches, withEvent: event)
        
        if UIMenuController.sharedMenuController().menuVisible == false {
            setBubbleBackgroundForNormalState()
        }
    }
    
    func copySelected() {
        setBubbleBackgroundForNormalState()
        UIPasteboard.generalPasteboard().string = messageTextNode.attributedString.string
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    private func setBubbleBackgroundForNormalState() {
        if outgoingMessage == true {
            bubbleNode.tintColor = outgoingMessageColorNormal
        } else {
            bubbleNode.tintColor = incomingMessageColorNormal
        }
    }
    
    private func setBubbleBackgroundForSelectedState() {
        if outgoingMessage == true {
            bubbleNode.tintColor = outgoingMessageColorSelected
        } else {
            bubbleNode.tintColor = incomingMessageColorSelected
        }
    }

}
