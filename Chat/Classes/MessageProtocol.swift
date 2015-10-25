//
//  MessageProtocol.swift
//  Chat
//
//  Created by Petr Pavlik on 23/10/15.
//  Copyright © 2015 Petr Pavlik. All rights reserved.
//

import Foundation

protocol MessageProtocol {
    
    // Use this to override global avatar URL set on ChatViewController
    var avatarURL: NSURL? { get }
    
}

protocol TextMessageProtocol: MessageProtocol {
    
    var text: String { get }
}