//
//  ChatToolbar.swift
//  Chat
//
//  Created by Petr Pavlik on 26/09/15.
//  Copyright © 2015 Petr Pavlik. All rights reserved.
//

import UIKit

public class ChatInputBar: UIView, UITextViewDelegate {
    
    public var keyboardFrameChangedBlock: ((frame: CGRect) -> Void)?
    public var sizeUpdateRequiredBlock: (() -> Void)?
    
    private var requiredHeight: CGFloat = 44

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
    
    private func configureView() {
        
        addSubview(textView)
        addSubview(sendButton)
        
        backgroundColor = .whiteColor()
        
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
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[separatorView(0.5)][textView]|", options: NSLayoutFormatOptions(), metrics: nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|->=0-[sendButton(44)]|", options: NSLayoutFormatOptions(), metrics: nil, views: bindings))
        
        textView.delegate = self
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func textViewDidChange(textView: UITextView) {
        
        let requiredSize = textView.attributedText.boundingRectWithSize(CGSizeMake(textView.frame.width, 1000), options: [NSStringDrawingOptions.UsesLineFragmentOrigin, NSStringDrawingOptions.UsesFontLeading], context: nil).size
        
        if requiredHeight == max(44, requiredSize.height) {
            return
        }
        
        requiredHeight = max(44, requiredSize.height)
        
        sizeUpdateRequiredBlock?()
    }
    
    public override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(320, requiredHeight)
    }
    
}
