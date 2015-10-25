//
//  ChatViewController.swift
//  Chat
//
//  Created by Petr Pavlik on 23/10/15.
//  Copyright © 2015 Petr Pavlik. All rights reserved.
//

import UIKit

protocol ChatViewControllerDataSource {
    func messageForIndex(index: UInt) -> MessageProtocol
    func numberOfMessages() -> UInt
}

class ChatViewController: UIViewController {

}
