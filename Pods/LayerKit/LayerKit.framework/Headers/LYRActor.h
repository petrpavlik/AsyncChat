//
//  LYRActor.h
//  LayerKit
//
//  Created by Kabir Mahal on 4/21/15.
//  Copyright (c) 2015 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRQuery.h"
#import "LYRConstants.h"

/**
 @abstract The `LYRActor` class represents a message sender as either an authenticated user or a platform message.
 */
@interface LYRActor : NSObject

/**
 @abstract The userID of the authenticated user who sent the message.  Previously `sentByUserID`.
 @discussion The `userID` property is queryable via the `LYRPredicateOperatorIsEqualTo` and `LYRPredicateOperatorIsNotEqualTo` predicate operators.
 */

@property (nonatomic, readonly) NSString *userID LYR_QUERYABLE_FROM(LYRMessage) LYR_QUERYABLE_FROM(LYRConversation);;

/**
 @abstract The name of the platform that sent the message, not an authenticated user.
 @discussion The `userID` property is queryable via the `LYRPredicateOperatorIsEqualTo` and `LYRPredicateOperatorIsNotEqualTo` predicate operators.
 */

@property (nonatomic, readonly) NSString *name LYR_QUERYABLE_FROM(LYRMessage) LYR_QUERYABLE_FROM(LYRConversation);;

@end
