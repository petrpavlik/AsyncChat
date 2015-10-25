//
//  ViewController.swift
//  Chat
//
//  Created by Petr Pavlik on 26/09/15.
//  Copyright © 2015 Petr Pavlik. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class TextMessage: TextMessageProtocol {
    
    init(text: String) {
        self.text = text
    }
    
    var avatarURL: NSURL?
    var text: String
}

class ImageMessage: MessageProtocol {
    
    init(imageURL: NSURL) {
        self.imageURL = imageURL
    }
    
    var avatarURL: NSURL?
    var imageURL: NSURL
}

class ViewController: UIViewController, ASTableViewDataSource, ASTableViewDelegate, ChatViewControllerDataSource {
    
    private var messages: [MessageProtocol] = [
        TextMessage(text: "三多摩地区開発による沿線人口の増加、相模原線延伸による多摩ニュータウン乗り入れ、都営地下鉄10号線（後の都営地下鉄新宿線、以下、新宿線と表記する）乗入構想により、京王線の利用客増加が見込まれ、相当数の車両を準備する必要に迫られるなか、製造費用、保守費用を抑えた新型車両として6000系が構想された[22]。新宿線建設に際してはすでに1号線（後の浅草線"),
        TextMessage(text: "AsyncDisplayKit is an iOS framework that keeps even the most complex user interfaces smooth and responsive. It was originally built to make Facebook's Paper possible, and goes hand-in-hand with pop's physics-based animations — but it's just as powerful with UIKit Dynamics and conventional app designs. www.google.com"),
        TextMessage(text: "Good morning"),
        TextMessage(text: "EMOJIS!!!! Told ya, you can't use them omb 😂😂😂😂😂😂😂"),
        TextMessage(text: "x"),
        ImageMessage(imageURL: NSURL(string: "https://pbs.twimg.com/media/CRtEnJpXAAAqUt7.jpg:large")!)
    ]
    
    func messageForIndex(index: UInt) -> MessageProtocol {
        return messages[Int(index)]
    }
    
    func numberOfMessages() -> UInt {
        return UInt(messages.count)
    }
    
    private let inputBar = ChatInputBar()
    private var inputBarBottomOffset: CGFloat = 0
    
    enum Sections: Int {
        case LoadingIndicator = 0, Content, TypingIndicator
    }

    let tableView = ASTableView(frame: CGRectZero, style: .Plain)
    
    var typing = false {
        didSet {
            if tableView.numberOfSections > 0 {
                tableView.beginUpdates()
                tableView.reloadSections(NSIndexSet(index: Sections.TypingIndicator.rawValue), withRowAnimation: .Automatic)
                tableView.endUpdatesAnimated(!typing, completion: { (completed: Bool) -> Void in
                    assert(NSThread.isMainThread())
                    if self.typing == true {
                        self.scrollToBottom(true)
                    }
                })
            }
        }
    }
    
    override func loadView() {
        super.loadView()
        
        tableView.asyncDataSource = self
        tableView.asyncDelegate = self
        tableView.separatorStyle = .None
        tableView.keyboardDismissMode = .Interactive
        tableView.frame = view.bounds
        view.addSubview(tableView)
        
        view.addSubview(inputBar)
        inputBar.frame = CGRectMake(0, 0, inputBar.intrinsicContentSize().width, inputBar.intrinsicContentSize().height)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        title = "Async Chat"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardNotification:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        
        tableView.reloadDataWithCompletion { () -> Void in
            self.reactToKeyboardFrameChange()
            self.scrollToBottom(false)
        }
        
        inputBar.keyboardFrameChangedBlock = { [weak self] (frame: CGRect) in
            
            self?.inputBarBottomOffset = self!.view.bounds.height - frame.origin.y
            self?.inputBar.pspdf_performWithoutTriggeringSetNeedsLayout({ () -> Void in
                self!.inputBar.frame = CGRectMake(0, self!.view.bounds.height-self!.inputBar.intrinsicContentSize().height-self!.inputBarBottomOffset, self!.view.bounds.width, self!.inputBar.intrinsicContentSize().height)
                self!.reactToKeyboardFrameChange()
            })
        }
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
            self?.typing = true
        }
        
        //startSwitchingTypingState()
        //startAddingMessages()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = CGRectMake(0, topLayoutGuide.length, view.bounds.width, view.bounds.height - topLayoutGuide.length)
        inputBar.frame = CGRectMake(0, view.bounds.height-self.inputBar.intrinsicContentSize().height-inputBarBottomOffset, view.bounds.width, inputBar.intrinsicContentSize().height)
    }
    
    // MARK:
    
    func tableView(tableView: ASTableView!, nodeForRowAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
        
        if indexPath.section == Sections.Content.rawValue {
            
            let isIncoming = indexPath.row != 2
            
            if let message = messageForIndex(UInt(indexPath.row)) as? TextMessage {
                let cellNode = ChatCellNode(message: message.text, isIncomming: isIncoming)
                if isIncoming == true {
                    cellNode.avatarImageNode.setURL(NSURL(string: "https://pbs.twimg.com/profile_images/477397164453527552/uh2w1u1o.jpeg")!, resetToDefault: true)
                }
                return cellNode
            } else if let message = messageForIndex(UInt(indexPath.row)) as? ImageMessage {
                let cellNode = ImageMessageCell(imageURL: message.imageURL, isIncomming: isIncoming)
                if isIncoming == true {
                    cellNode.avatarImageNode.setURL(NSURL(string: "https://pbs.twimg.com/profile_images/477397164453527552/uh2w1u1o.jpeg")!, resetToDefault: true)
                }
                return cellNode
            }
            
        } else if indexPath.section == Sections.LoadingIndicator.rawValue {
            return LoadingCellNode()
        } else {
            let cellNode = TypingMessageCell()
            cellNode.configure(NSURL(string: "https://pbs.twimg.com/profile_images/477397164453527552/uh2w1u1o.jpeg")!)
            return cellNode
        }
        
        return nil
    }
    
    func tableView(tableView: ASTableView!, willDisplayNodeForRowAtIndexPath indexPath: NSIndexPath!) {
        if indexPath.section == Sections.LoadingIndicator.rawValue {
            let loadingCellNode = tableView.nodeForRowAtIndexPath(indexPath) as! LoadingCellNode
            loadingCellNode.startAnimating()
        } else if indexPath.section == Sections.TypingIndicator.rawValue {
            let typingCellNode = tableView.nodeForRowAtIndexPath(indexPath) as! TypingMessageCell
            typingCellNode.startAnimating()
        }
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case Sections.Content.rawValue: return Int(numberOfMessages())
            case Sections.TypingIndicator.rawValue: return Int(typing == true)
            case Sections.LoadingIndicator.rawValue: return 1
            default: return 0
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 3
    }
    
    //MARK: 
    
    private func scrollToBottom(animated: Bool) {
        
        if tableView.numberOfSections == 0 {
            return
        }
        
        let indexPath: NSIndexPath!
        if tableView.numberOfRowsInSection(Sections.TypingIndicator.rawValue) > 0 {
            indexPath = NSIndexPath(forRow: 0, inSection: Sections.TypingIndicator.rawValue)
        } else if tableView.numberOfRowsInSection(Sections.Content.rawValue) > 0 {
            indexPath = NSIndexPath(forRow: messages.count-1, inSection: Sections.Content.rawValue)
        } else {
            return
        }
        
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Bottom, animated: animated)
        
        //tableView.setContentOffset(CGPointMake(0, tableView.contentSize.height - tableView.bounds.height + tableView.contentInset.bottom), animated: true)
    }
    
    private func reactToKeyboardFrameChange() {
        tableView.contentInset = UIEdgeInsetsMake(0, 0, inputBarBottomOffset+self.inputBar.frame.height, 0)
        tableView.scrollIndicatorInsets = tableView.contentInset
    }
    
    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
            print("frame changed \(endFrame)")
            let duration:NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            
            if UIScreen.mainScreen().bounds.height - endFrame!.origin.y > 0 {
                inputBarBottomOffset = endFrame!.size.height
            } else {
                inputBarBottomOffset = 0
            }
            
            self.inputBar.pspdf_performWithoutTriggeringSetNeedsLayout({ () -> Void in
                UIView.animateWithDuration(duration,
                    delay: NSTimeInterval(0),
                    options: animationCurve,
                    animations: {
                        self.inputBar.frame = CGRectMake(0, self.view.bounds.height-self.inputBar.intrinsicContentSize().height-self.inputBarBottomOffset, self.view.bounds.width, self.inputBar.intrinsicContentSize().height)
                        self.reactToKeyboardFrameChange()
                    },
                    completion: nil)
            })
        }
    }
    
    //MARK: Debug
    
    func startSwitchingTypingState() {
        typing = !typing
        if typing == true {
            scrollToBottom(true)
        }
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
            self?.startSwitchingTypingState()
        }
    }
    
    func startAddingMessages() {
        if tableView.numberOfSections > 0 {
            messages.append(TextMessage(text: "New message \(NSDate())"))
            tableView.beginUpdates()
            tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: messages.count-1, inSection: Sections.Content.rawValue)], withRowAnimation: .Automatic)
            tableView.endUpdatesAnimated(false, completion: { (completed: Bool) -> Void in
                self.scrollToBottom(true)
            })
        }
    
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(6 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
            self?.startAddingMessages()
        }
    }
    
}

