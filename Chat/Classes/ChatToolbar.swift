//
//  ChatToolbar.swift
//  Chat
//
//  Created by Petr Pavlik on 26/09/15.
//  Copyright © 2015 Petr Pavlik. All rights reserved.
//

import UIKit

class ChatInputBar: UIView, UITextViewDelegate {
    
    var keyboardFrameChangedBlock: ((frame: CGRect) -> Void)?

    private let textView: UITextView = {
       let textView = UITextView()
        textView.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        textView.text = "aaa"
        return textView
    }()
    
    private let sendButton: UIButton = {
        let button = UIButton(type: .System)
        button.setTitle(NSLocalizedString("Send", comment: ""), forState: .Normal)
        return button
    }()
    
    private var textViewHeightConstraints = [NSLayoutConstraint]()
    
    private func configureView() {
        
        addSubview(textView)
        addSubview(sendButton)
        
        let separatorView = UIView()
        separatorView.backgroundColor = UIColor(red:0.741, green:0.741, blue:0.741, alpha: 1)
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separatorView)
        
        textView.textContainer.lineFragmentPadding = 0
        textView.contentInset = UIEdgeInsetsZero
        
        let detectorView = KeyboardFrameDetectorInputView()
        detectorView.keyboardFrameChangedBlock = { [weak self] (frame: CGRect) in
            self?.keyboardFrameChangedBlock?(frame: frame)
        }
        
        textView.inputAccessoryView = detectorView
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        let bindings = ["textView": textView, "sendButton": sendButton, "separatorView": separatorView]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[separatorView]|", options: NSLayoutFormatOptions(), metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-[textView]-[sendButton]-|", options: NSLayoutFormatOptions(), metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[separatorView(1)][textView]|", options: NSLayoutFormatOptions(), metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|->=0-[sendButton(44)]|", options: NSLayoutFormatOptions(), metrics: nil, views: bindings))
        
        textView.delegate = self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func textViewDidChange(textView: UITextView) {
        
        let requiredSize = textView.attributedText.boundingRectWithSize(CGSizeMake(textView.frame.width, 1000), options: [NSStringDrawingOptions.UsesLineFragmentOrigin, NSStringDrawingOptions.UsesFontLeading], context: nil).size
        
        let requiredHeight = max(44, requiredSize.height)
        
        print("\(requiredHeight)")
        
        removeConstraints(textViewHeightConstraints)
        textViewHeightConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[textView(height)]", options: NSLayoutFormatOptions(), metrics: ["height": requiredHeight], views: ["textView": textView])
        addConstraints(textViewHeightConstraints)
        
        UIView.animateWithDuration(0.2) { () -> Void in
            self.layoutIfNeeded()
        } 
    }
    
}
