//
//  LoadingCellNode.swift
//  Chat
//
//  Created by Petr Pavlik on 03/10/15.
//  Copyright © 2015 Petr Pavlik. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class LoadingCellNode: ASCellNode {
    
    private let loadingNode = ASDisplayNode { () -> UIView! in
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator.hidesWhenStopped = false
        return activityIndicator
    }
    
    override init!() {
        super.init()
        
        addSubnode(loadingNode)
    }
    
    override func calculateSizeThatFits(constrainedSize: CGSize) -> CGSize {
        return CGSizeMake(constrainedSize.width, 44)
    }
    
    override func layout() {
        loadingNode.frame = CGRectMake((bounds.width-20)/2, (bounds.height-20)/2, 20, 20)
    }
    
    func startAnimating() {
        assert(NSThread.isMainThread())
        
        let activityIndicator = loadingNode.view as! UIActivityIndicatorView
        activityIndicator.startAnimating()
    }

}
