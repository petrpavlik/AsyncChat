//
//  UIView+PSPDFKitAdditions.m
//  Tastebuds
//
//  Created by Petr Pavlik on 23/09/15.
//  Copyright © 2015 Tastebuds Media Ltd. All rights reserved.
//

#import "UIView+PSPDFKitAdditions.h"

#import <objc/runtime.h>

static NSString *const PSPDFSuppressLayoutKey = @"pspdf_suppressSetNeedsLayout";

@interface PSPDFSuppressLayoutTriggerLayer : CALayer @end
@implementation PSPDFSuppressLayoutTriggerLayer

- (void)setNeedsLayout {
    if (![[self valueForKey:PSPDFSuppressLayoutKey] boolValue]) {
        [super setNeedsLayout];
    }
}

@end

@implementation UIView (PSPDFKitAdditions)

- (void)pspdf_performWithoutTriggeringSetNeedsLayout:(dispatch_block_t)block {
    CALayer *layer = self.layer;
    // Change layer to be our custom subclass.
    if (![layer isKindOfClass:PSPDFSuppressLayoutTriggerLayer.class]) {
        // Check both classes to see and break if KVO is used here.
        if ([layer.class isEqual:CALayer.class] && [layer.class isEqual:object_getClass(layer)]) {
            object_setClass(self.layer, PSPDFSuppressLayoutTriggerLayer.class);
        }else {
            // While we could use dynamic subclassing, that amount of complexity isn't needed in our case.
            // If we're a different layer type, the generic KVC store value is simply ignored, so no need to quit.
            NSLog(@"View has a custom layer - not changing.");
        }
    }
    if (![[layer valueForKey:PSPDFSuppressLayoutKey] boolValue]) {
        [layer setValue:@YES forKey:PSPDFSuppressLayoutKey];
        block();
        [layer setValue:@NO forKey:PSPDFSuppressLayoutKey];
    }else {
        // No need to set flag again. Allows to be called this multiple times.
        block();
    }
}

@end