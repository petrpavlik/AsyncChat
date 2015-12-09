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

public class ChatCellNode: MessageCell, ASTextNodeDelegate {
    
    var incomingMessageTextColor = UIColor.blackColor()
    var outgoingMessageTextColor = UIColor.whiteColor()
    
    
    let messageTextNode = ASTextNode()
    
    var bubbleTextMargin: CGFloat = 10
    
    public init(message: String, isIncoming: Bool) {
        super.init()
        
        addSubnode(messageTextNode)
        
        messageTextNode.passthroughNonlinkTouches = true
        
        messageTextNode.delegate = self
        messageTextNode.userInteractionEnabled = true
        messageTextNode.linkAttributeNames = ["aaa"]
        
        
        isIncomingMessage = isIncoming
        
        let attributes = [NSFontAttributeName: UIFont.systemFontOfSize(17), NSForegroundColorAttributeName: isIncoming == true ? incomingMessageTextColor : outgoingMessageTextColor]
        let attributedString = NSAttributedString(string: message, attributes: attributes).mutableCopy() as! NSMutableAttributedString
        
        avatarImageNode.hidden = !isIncoming
        //avatarImageNode.setURL(avatarURL, resetToDefault: false)
        
        let types: NSTextCheckingType = [.Link, .PhoneNumber]
        let detector = try? NSDataDetector(types: types.rawValue)
        detector?.enumerateMatchesInString(message, options: [], range: NSMakeRange(0, (message as NSString).length)) { (result, flags, _) in
            if let URL = result?.URL {
                attributedString.addAttribute("aaa", value: URL, range: result!.range)
                //attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor(), range: result!.range)
                attributedString.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.StyleSingle.rawValue, range: result!.range)
            }
        }
        
        messageTextNode.attributedString = attributedString
        
        if isIncoming == true {
            bubbleNode.tintColor = incomingMessageColorNormal
        } else {
            bubbleNode.tintColor = outgoingMessageColorNormal
        }
    }
    
    override func layoutSpecForBubbneNode(bubbleNode: ASDisplayNode) -> ASLayoutSpec {
        
        let spec = ASInsetLayoutSpec(insets: UIEdgeInsetsMake(bubbleTextMargin, bubbleTextMargin, bubbleTextMargin, bubbleTextMargin), child: messageTextNode)
        
        return ASBackgroundLayoutSpec(child: spec, background: bubbleNode)
    }
    
    public func textNode(textNode: ASTextNode!, shouldHighlightLinkAttribute attribute: String!, value: AnyObject!, atPoint point: CGPoint) -> Bool {
        return true
    }
    
    public func textNode(textNode: ASTextNode!, shouldLongPressLinkAttribute attribute: String!, value: AnyObject!, atPoint point: CGPoint) -> Bool {
        return true
    }
    
    public func textNode(textNode: ASTextNode!, tappedLinkAttribute attribute: String!, value: AnyObject!, atPoint point: CGPoint, textRange: NSRange) {
        UIApplication.sharedApplication().openURL(value as! NSURL)
    }
    
    override public func didLoad() {
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
    
    override public func touchesBegan(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        super.touchesBegan(touches, withEvent: event)
        
        setBubbleBackgroundForSelectedState()
        
        if UIMenuController.sharedMenuController().menuVisible == true {
           UIMenuController.sharedMenuController().setMenuVisible(false, animated: true)
            setBubbleBackgroundForNormalState()
        }
    }
    
    override public func touchesEnded(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        super.touchesEnded(touches, withEvent: event)
        
        if UIMenuController.sharedMenuController().menuVisible == false {
            setBubbleBackgroundForNormalState()
        }
    }
    
    override public func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        super.touchesCancelled(touches, withEvent: event)
        
        if UIMenuController.sharedMenuController().menuVisible == false {
            setBubbleBackgroundForNormalState()
        }
    }
    
    func copySelected() {
        setBubbleBackgroundForNormalState()
        UIPasteboard.generalPasteboard().string = messageTextNode.attributedString.string
    }
    
    override public func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    private func setBubbleBackgroundForNormalState() {
        if isIncomingMessage == false {
            bubbleNode.tintColor = outgoingMessageColorNormal
        } else {
            bubbleNode.tintColor = incomingMessageColorNormal
        }
    }
    
    private func setBubbleBackgroundForSelectedState() {
        if isIncomingMessage == false {
            bubbleNode.tintColor = outgoingMessageColorSelected
        } else {
            bubbleNode.tintColor = incomingMessageColorSelected
        }
    }

}
