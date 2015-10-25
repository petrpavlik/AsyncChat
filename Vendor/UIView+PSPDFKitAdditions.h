//
//  UIView+PSPDFKitAdditions.h
//  Tastebuds
//
//  Created by Petr Pavlik on 23/09/15.
//  Copyright © 2015 Tastebuds Media Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (PSPDFKitAdditions)

// Allows to change frame/bounds without triggering `layoutSubviews` on the parent.
// Not needed for changes that are performed within `layoutSubviews`.
- (void)pspdf_performWithoutTriggeringSetNeedsLayout:(dispatch_block_t)block;

@end
