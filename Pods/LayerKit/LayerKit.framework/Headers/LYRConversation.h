//
//  LYRConversation.h
//  LayerKit
//
//  Created by Klemen Verdnik on 06/05/14.
//  Copyright (c) 2014 Layer Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LYRQuery.h"
#import "LYRConstants.h"

@class LYRMessage;

///---------------------------
/// @name Conversation Options
///---------------------------

/**
 @abstract The option key for configuring metadata during Conversation creation.
 @discussion The `LYRConversationOptionsMetadataKey` enables developers to configure metadata on the conversation at the moment it is created, guaranteeing that the
 metadata will be available on the conversation when the change notification is published. The value given must be an `NSDictionary` of `NSString` key-value pairs. The 
 functionality provided is identical to calling `setValuesForMetadataKeyPathsWithDictionary:merge:` with a `merge` argument of `NO` on the conversation after initialization.
 */
extern NSString *const LYRConversationOptionsMetadataKey;

/**
 @abstract The option key for configuring whether or not clients should write delivery receipts for messages in the conversation.
 @discussion When `YES`, clients will write delivery receipts and a delineation will be made between `LYRRecipientStatusSent` and `LYRRecipientStatusDelivered`. When `NO`,
 messages will remain in the `LYRRecipientStatusSent` state until explicitly marked as read. Disabling delivery receipts improves performance for conversations that
 do not benefit from them.
 */
extern NSString *const LYRConversationOptionsDeliveryReceiptsEnabledKey;

/**
 @abstract The option key for configuring whether or not Conversations are created such that they are guaranteed to be a single distinctive Conversation among the set of participants.
 @discussion Because Layer supports offline use-cases and sets of users may attempt to communicate among identical groups concurrently, it is possible to inadvertently create Conversations that
 from the end-user perspective appear as separate threads where they were expecting a single one to exist. This behavior can be addressed by requesting Layer to create a Conversation that is distinct
 among the set of participants via the `LYRConversationOptionsDistinctByParticipantsKey` option key. When `YES`, Layer will guarantee that among the initial set of participants there will exist one (and only one)
 distinct Conversation. This guarantee will persist until the participants list is modified as the mutation may result in an overlap with existing Conversations. When `NO`, the distinctive guarantee is not requested
 and a new Conversation will be created among the set of participants without regard for any existing Conversations
 (distinct or otherwise).
 */
extern NSString *const LYRConversationOptionsDistinctByParticipantsKey;

//------------------------------------------------------------

/**
 @abstract The `LYRConversation` class models a conversations between two or more participants within Layer. A conversation is an
 on-going stream of messages (modeled by the `LYRMessage` class) synchronized among all participants.
 */
@interface LYRConversation : NSObject <LYRQueryable>

/**
 @abstract A unique identifier assigned to every conversation by Layer.
 @discussion The `identifier` property is queryable via the `LYRPredicateOperatorIsEqualTo`, `LYRPredicateOperatorIsNotEqualTo`, `LYRPredicateOperatorIsIn`, and `LYRPredicateOperatorIsNotIn` operators.
 */
@property (nonatomic, readonly) NSURL *identifier LYR_QUERYABLE_PROPERTY;

/**
 @abstract The set of user identifiers's specifying who is participating in the conversation modeled by the receiver.
 @discussion Layer conversations are addressed using the user identifiers of the host application. These user ID's are transmitted to
 Layer as part of the Identity Token during authentication. User ID's are commonly modeled as the primary key, email address, or username
 of a given user withinin the backend application acting as the identity provider for the Layer-enabled mobile application.
 
 The `participants` property is queryable via the `LYRPredicateOperatorIsEqualTo`, `LYRPredicateOperatorIsNotEqualTo`, `LYRPredicateOperatorIsIn`, and `LYRPredicateOperatorIsNotIn` operators. For convenience, 
 queries with an equality predicate (`LYRPredicateOperatorIsEqualTo` and `LYRPredicateOperatorIsNotEqualTo`) for the `participants` property will implicitly include the authenticated user.
 */
@property (nonatomic, readonly) NSSet *participants LYR_QUERYABLE_PROPERTY;

/**
 @abstract The date and time that the conversation was created.
 @discussion This value specifies the time that receiver was locally created and will vary across devices.
 
 The `createdAt` property is queryable using all predicate operators.
 */
@property (nonatomic, readonly) NSDate *createdAt LYR_QUERYABLE_PROPERTY;

/**
 @abstract Returns the last Message recevied or sent in this Conversation.
 @discussion May be `nil`, if no messages exist in the conversation.
 
 The `lastMessage` property is queryable via the `LYRPredicateOperatorIsEqualTo`, `LYRPredicateOperatorIsNotEqualTo`, `LYRPredicateOperatorIsIn`, and `LYRPredicateOperatorIsNotIn` operators.
 */
@property (nonatomic, readonly) LYRMessage *lastMessage LYR_QUERYABLE_PROPERTY;

/**
 @abstract Returns a Boolean value that indicates if the receiver contains unread messages.
 @discussion The `hasUnreadMessages` property is queryable via the `LYRPredicateOperatorIsEqualTo` and `LYRPredicateOperatorIsNotEqualTo` predicate operators.
 */
@property (nonatomic, readonly) BOOL hasUnreadMessages LYR_QUERYABLE_PROPERTY;

/**
 @abstract Returns a Boolean value that indicates whether or not the conversation is a distinct conversation by its participant list. If YES, the Layer service gurantees that there will only be one conversation created between the current set of participants.
 @discussion The `isDistinct` property is queryable via the `LYRPredicateOperatorIsEqualTo` and `LYRPredicateOperatorIsNotEqualTo` predicate operators.
 @default YES.
 */
@property (nonatomic, readonly) BOOL isDistinct LYR_QUERYABLE_PROPERTY;

/**
 @abstract Returns a Boolean value that indicates if the receiver has been deleted.
 */
@property (nonatomic, readonly) BOOL isDeleted;

/**
 @abstract Returns a Boolean value that indicates if delivery receipts are enabled. When `YES`, clients will write delivery receipts and a delineation will be made between `LYRRecipientStatusSent`
 and `LYRRecipientStatusDelivered`. When `NO`, messages will remain in the `LYRRecipientStatusSent` state until explicitly marked as read.
 @discussion When delivery receipts are enabled, client devices will acknowledge delivery of messages by writing a synchronized delivery receipt. This provides more granular message
 status, but results in more synchronization activity. Developers are encouraged to disabled delivery receipts if the delivery status is unimportant or unused.
 */
@property (nonatomic, readonly) BOOL deliveryReceiptsEnabled;

///-----------------------
/// @name Sending Messages
///-----------------------

/**
 @abstract Sends the specified message.
 @discussion The message is enqueued for delivery during the next synchronization after basic local validation of the message state is performed. Validation
 that may be performed includes checking that the maximum number of participants has not been execeeded and that parts of the message do not have an aggregate
 size in excess of the maximum for a message.
 @param message The message to be sent. Cannot be `nil`.
 @param error A pointer to an error object that, upon failure, will be set to an error describing why the message could not be sent.
 @return A Boolean value indicating if the message passed validation and was enqueued for delivery.
 @raises NSInvalidArgumentException Raised if `message` is `nil`.
 */
- (BOOL)sendMessage:(LYRMessage *)message error:(NSError **)error;

///----------------------------
/// @name Managing Participants
///----------------------------

/**
 @abstract Adds participants to a given conversation.
 @param participants A set of `providerUserID` in a form of `NSString` objects.
 @param error A pointer to an error object that, upon failure, will be set to an error describing why the participants could not be added to the conversation.
 @return A Boolean value indicating if the operation of adding participants was successful.
 */
- (BOOL)addParticipants:(NSSet *)participants error:(NSError **)error;

/**
 @abstract Removes participants from a given conversation.
 @param participants A set of `providerUserID` in a form of `NSString` objects.
 @param error A pointer to an error object that, upon failure, will be set to an error describing why the participants could not be removed from the conversation.
 @return A Boolean value indicating if the operation of removing participants was successful.
 */
- (BOOL)removeParticipants:(NSSet *)participants error:(NSError **)error;

///------------------------
/// @name Managing Metadata
///------------------------

/**
 @abstract Returns the metadata associated with the conversation.
 @discussion Metadata is a free form dictionary of string key-value pairs that allows arbitrary developer supplied information to be associated with the conversation and synchronized among the participants.

 The `metadata` property is queryable in 2 forms.  The first is key path form eg:`metadata.first.second`, and is queryable via the `LYRPredicateOperatorIsEqualTo`, `LYRPredicateOperatorIsNotEqualTo`, 
 `LYRPredicateOperatorIsIn`, and `LYRPredicateOperatorIsNotIn` operators.  The second is querying against `metadata` and passing in a dictionary object value, and is only queryable via the `LYRPredicateOperatorIsEqualTo` operator.
 */
@property (nonatomic, readonly) NSDictionary *metadata LYR_QUERYABLE_PROPERTY;

/**
 @abstract Sets the value for the specified key path in the metadata dictionary.
 @param value The string or dictionary value to set for the given key path in the metadata.
 @param keyPath A key path into the metadata dictionary specifying where the value is to be set.
 */
- (void)setValue:(id)value forMetadataAtKeyPath:(NSString *)keyPath;

/**
 @abstract Sets multiple values on the metadata using an input dictionary, optionally merging with any existing values.
 @param metadata A dictionary of metadata to assign or merge with the existing metadata.
 @param merge A Boolean flag that specifies whether the metadata is to be assigned directly or merged with any existing values.
 */
- (void)setValuesForMetadataKeyPathsWithDictionary:(NSDictionary *)metadata merge:(BOOL)merge;

/**
 @abstract Deletes a specific value by key path from the metadata dictionary.
 @param keyPath A key path into the metadata dictionary specifying the value to be deleted.
 */
- (void)deleteValueForMetadataAtKeyPath:(NSString *)keyPath;

///------------------------
/// @name Typing Indicators
///------------------------

/**
 @abstract Sends a typing indicator to the conversation.
 @param typingIndicator An `LYRTypingIndicator` value indicating the change in typing state to be sent.
 */
- (void)sendTypingIndicator:(LYRTypingIndicator)typingIndicator;

///--------------------------------
/// @name Deleting the Conversation
///--------------------------------

/**
 @abstract Deletes a conversation in the specified mode.
 @discussion This method deletes a conversation and all associated messages for all current participants.
 @param mode The deletion mode, specifying how the message is to be deleted (i.e. locally or synchronized across participants).
 @param error A pointer to an error that upon failure is set to an error object describing why the deletion failed.
 @return A Boolean value indicating if the request to delete the conversation was submitted for synchronization.
 @raises NSInvalidArgumentException Raised if `message` is `nil`.
 */
- (BOOL)delete:(LYRDeletionMode)deletionMode error:(NSError **)error;

///-----------------------------------
/// @name Marking All Messages as Read
///-----------------------------------

/**
 @abstract Marks all messages in the receiver as being read by the current user.
 @param error A pointer to an error object that, upon failure, will be set to an error describing why the messages could not be marked as read.
 @return `YES` if all unread messages were marked as read or `NO` if an error occurred.
 */
- (BOOL)markAllMessagesAsRead:(NSError **)error;

@end

@interface LYRConversation (Deprecated_Nonfunctional)

// Deprecated. Use `LYRClient newConversationWithParticipants:options:error:` instead.
+ (instancetype)conversationWithParticipants:(NSSet *)participants __deprecated;

@end
