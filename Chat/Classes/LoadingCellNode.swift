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
    
    private class ActivityIndicatorNode: ASDisplayNode {
        private override func didLoad() {
            super.didLoad()
            
            let activityIndicator = view as! UIActivityIndicatorView
            activityIndicator.startAnimating()
        }
    }
    
    private let loadingNode = ActivityIndicatorNode { () -> UIView! in
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator.startAnimating()
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

}
