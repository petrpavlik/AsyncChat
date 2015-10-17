//
//  ViewController.swift
//  Chat
//
//  Created by Petr Pavlik on 26/09/15.
//  Copyright © 2015 Petr Pavlik. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ASTableViewDataSource, ASTableViewDelegate {
    
    private var messages = [
        "三多摩地区開発による沿線人口の増加、相模原線延伸による多摩ニュータウン乗り入れ、都営地下鉄10号線（後の都営地下鉄新宿線、以下、新宿線と表記する）乗入構想により、京王線の利用客増加が見込まれ、相当数の車両を準備する必要に迫られるなか、製造費用、保守費用を抑えた新型車両として6000系が構想された[22]。新宿線建設に際してはすでに1号線（後の浅草線",
        "AsyncDisplayKit is an iOS framework that keeps even the most complex user interfaces smooth and responsive. It was originally built to make Facebook's Paper possible, and goes hand-in-hand with pop's physics-based animations — but it's just as powerful with UIKit Dynamics and conventional app designs.",
        "Good morning",
        "EMOJIS!!!! Told ya, you can't use them omb 😂😂😂😂😂😂😂",
        "x"
    ]
    
    private let inputBar = ChatInputBar()
    private var inputBarBottomOffsetConstraint: NSLayoutConstraint!
    
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
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        tableView.separatorStyle = .None
        tableView.keyboardDismissMode = .Interactive
        view.addSubview(tableView)
        
        view.addSubview(inputBar)
        inputBar.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[inputBar]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["inputBar": inputBar]))
        
        let heightConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[inputBar]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["inputBar": inputBar])
        inputBarBottomOffsetConstraint = heightConstraints.first
        view.addConstraints(heightConstraints)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardNotification:", name: UIKeyboardWillChangeFrameNotification, object: nil)
        
        
        tableView.reloadDataWithCompletion { () -> Void in
            self.reactToKeyboardFrameChange()
            self.scrollToBottom(false)
        }
        
        startSwitchingTypingState()
        startAddingMessages()
    }
    
    // MARK:
    
    func tableView(tableView: ASTableView!, nodeForRowAtIndexPath indexPath: NSIndexPath!) -> ASCellNode! {
        
        if indexPath.section == Sections.Content.rawValue {
            let cellNode = ChatCellNode()
            if indexPath.row == 2 {
                cellNode.configureOutgoingMessage(messages[indexPath.row])
            } else {
                cellNode.configureIncommingMessage(messages[indexPath.row], avatarURL: NSURL(string: "https://pbs.twimg.com/profile_images/477397164453527552/uh2w1u1o.jpeg")!)
            }
            return cellNode
        } else if indexPath.section == Sections.LoadingIndicator.rawValue {
            return LoadingCellNode()
        } else {
            return TypingCellNode()
        }
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case Sections.Content.rawValue: return 5
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
        tableView.contentInset = UIEdgeInsetsMake(0, 0, self.inputBarBottomOffsetConstraint.constant+self.inputBar.frame.height, 0)
        tableView.scrollIndicatorInsets = tableView.contentInset
    }
    
    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue()
            let duration:NSTimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.unsignedLongValue ?? UIViewAnimationOptions.CurveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            self.inputBarBottomOffsetConstraint.constant = endFrame?.size.height ?? 0.0
            UIView.animateWithDuration(duration,
                delay: NSTimeInterval(0),
                options: animationCurve,
                animations: {
                    self.view.layoutIfNeeded()
                    self.reactToKeyboardFrameChange()
                },
                completion: nil)
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
            messages.append("New message \(NSDate())")
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

