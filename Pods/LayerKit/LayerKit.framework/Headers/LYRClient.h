//
//  LYRClient.h
//  LayerKit
//
//  Created by Klemen Verdnik on 7/23/13.
//  Copyright (c) 2013 Layer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "LYRConversation.h"
#import "LYRMessage.h"
#import "LYRMessagePart.h"
#import "LYRAnnouncement.h"
#import "LYRConstants.h"
#import "LYRPolicy.h"
#import "LYRProgress.h"

@class LYRClient, LYRQuery, LYRQueryController;

///-------------------------------------
/// @name Client Lifecycle Notifications
///-------------------------------------

/**
 @abstract Posted when a client has authenticated successfully.
 */
extern NSString *const LYRClientDidAuthenticateNotification;

/**
 @abstract A key into the user info dictionary of a `LYRClientDidAuthenticateNotification` notification specifying the user ID of the authenticated user.
 */
extern NSString *const LYRClientAuthenticatedUserIDUserInfoKey;

/**
 @abstract Posted when a client has deauthenticated.
 */
extern NSString *const LYRClientDidDeauthenticateNotification;

/**
 @abstract Posted when a client is beginning a synchronization operation.
 */
extern NSString *const LYRClientWillBeginSynchronizationNotification;

/**
 @abstract Posted when a client has finished a synchronization operation.
 */
extern NSString *const LYRClientDidFinishSynchronizationNotification;

///---------------------------
/// @name Change Notifications
///---------------------------

/**
 @abstract Posted when the objects associated with a client have changed due to local mutation or synchronization activities.
 @discussion The Layer client provides a flexible notification system for informing applications when changes have
 occured on domain objects in response to local mutation or synchronization activities. The system is designed to be general
 purpose and models changes as the creation, update, or deletion of an object. Changes are modeled as `LYRObjectChange` objects.
 @see LYRConstants.h
 */
extern NSString *const LYRClientObjectsDidChangeNotification;

/**
 @abstract The key into the `userInfo` of a `LYRClientObjectsDidChangeNotification` notification for an array of changes.
 @discussion Each element in array retrieved from the user info for the `LYRClientObjectChangesUserInfoKey` key is an `LYRObjectChange` object which models a
 single object change event for a Layer model object. The `LYRObjectChange` contains information about the object that changed, what type of
 change occurred (create, update, or delete) and additional details for updates such as the property that changed and its value before and after mutation.
 Change notifications are emitted after synchronization has completed and represent the current state of the Layer client's database.
 @see LYRConstants.h
 */
extern NSString *const LYRClientObjectChangesUserInfoKey;

/**
 @abstract Posted when the client has scheduled an attempt to connect to Layer.
 */
extern NSString *const LYRClientWillAttemptToConnectNotification;

/**
 @abstract Posted when the client has successfully connected to Layer.
 */
extern NSString *const LYRClientDidConnectNotification;

/**
 @abstract Posted when the client has lost an established connection to Layer.
 */
extern NSString *const LYRClientDidLoseConnectionNotification;

/**
 @abstract Posted when the client has lost the connection to Layer.
 */
extern NSString *const LYRClientDidDisconnectNotification;

/**
 @abstract The key into the `userInfo` of the `LYRClientWillBeginSynchronizationNotification` whose value is the `LYRProgress` instance
 of the synchronization process in progress.
 @see LYRClientWillBeginSynchronizationNotification
 */
extern NSString *const LYRClientSynchronizationProgressUserInfoKey;

/**
 @abstract The key into the `userInfo` of the error object passed by the delegate method `layerClient:didFailOperationWithError:` describing
 which public API method encountered the failure.
 @see layerClient:didFailOperationWithError:
 */
extern NSString *const LYRClientOperationErrorUserInfoKey;

/**
 @abstract Posted when a conversation object receives a change in typing indicator state.
 @discussion The `object` of the `NSNotification` is the `LYRConversation` that received the typing indicator.
 */
extern NSString *const LYRConversationDidReceiveTypingIndicatorNotification;

/**
 @abstract A key into the user info of a `LYRConversationDidReceiveTypingIndicatorNotification` notification whose value is
 a `NSNumber` containing a unsigned integer whose value corresponds to a `LYRTypingIndicator`.
 */
extern NSString *const LYRTypingIndicatorValueUserInfoKey;

/**
 @abstract A key into the user info of a `LYRConversationDidReceiveTypingIndicatorNotification` notification whose value is
 a `NSString` specifying the participant who changed typing state.
 */
extern NSString *const LYRTypingIndicatorParticipantUserInfoKey;

/**
 @abstract Posted when the client will begin transfering content.
 */
extern NSString *const LYRClientWillBeginContentTransferNotification;

/**
 @abstract Posted when the client finishes the content transfer.
 */
extern NSString *const LYRClientDidFinishContentTransferNotification;

/**
 @abstract A key into the `userInfo` of either `LYRClientWillBeginContentTransferNotification`, or
 `LYRClientDidFinishContentTransferNotification` whose value is the `LYRContentTransferType`
 enum indicating either an upload or a download transfer type.
 */
extern NSString *const LYRClientContentTransferTypeUserInfoKey;

/**
 @abstract A key into the `userInfo` of either `LYRClientWillBeginContentTransferNotification`, or
 `LYRClientDidFinishContentTransferNotification` whose value is an `LYRMessagePart` instance
 of which the client did begin or finish the uploading or downloading process (depending
 on the transfer type).
 */
extern NSString *const LYRClientContentTransferObjectUserInfoKey;

/**
 @abstract A key into the `userInfo` of either `LYRClientWillBeginContentTransferNotification`, or
 `LYRClientDidFinishContentTransferNotification` whose value is an `LYRProgress` instance
 that tracks the transfer progress of object's content.
 */
extern NSString *const LYRClientContentTransferProgressUserInfoKey;

///----------------------
/// @name Client Delegate
///----------------------

/**
 @abstract The `LYRClientDelegate` protocol provides a method for notifying the adopting delegate about information changes.
 */
@protocol LYRClientDelegate <NSObject>

@required

/**
 @abstract Tells the delegate that the server has issued an authentication challenge to the client and a new Identity Token must be submitted.
 @discussion At any time during the lifecycle of a Layer client session the server may issue an authentication challenge and require that
 the client confirm its identity. When such a challenge is encountered, the client will immediately become deauthenticated and will no
 longer be able to interact with communication services until reauthenticated. The nonce value issued with the challenge must be submitted
 to the remote identity provider in order to obtain a new Identity Token.
 @see LayerClient#authenticateWithIdentityToken:completion:
 @param client The client that received the authentication challenge.
 @param nonce The nonce value associated with the challenge.
 */
- (void)layerClient:(LYRClient *)client didReceiveAuthenticationChallengeWithNonce:(NSString *)nonce;

@optional

/**
 @abstract Informs the delegate that the client is making an attempt to connect to Layer.
 @param client The client attempting the connection.
 @param attemptNumber The current attempt (of the attempt limit) that is being made.
 @param delayInterval The delay, if any, before the attempt will actually be made.
 @param attemptLimit The total number of attempts that will be made before the client gives up.
 */
- (void)layerClient:(LYRClient *)client willAttemptToConnect:(NSUInteger)attemptNumber afterDelay:(NSTimeInterval)delayInterval maximumNumberOfAttempts:(NSUInteger)attemptLimit;

/**
 @abstract Informs the delegate that the client has successfully connected to Layer.
 @param client The client that made the connection.
 */
- (void)layerClientDidConnect:(LYRClient *)client;

/**
 @abstract Informs the delegate that the client has lost an established connection with Layer due to an error.
 @param client The client that lost the connection.
 @param error The error that occurred.
 */
- (void)layerClient:(LYRClient *)client didLoseConnectionWithError:(NSError *)error;

/**
 @abstract Informs the delegate that the client has disconnected from Layer.
 @param client The client that has disconnected.
 */
- (void)layerClientDidDisconnect:(LYRClient *)client;

/**
 @abstract Tells the delegate that a client has successfully authenticated with Layer.
 @param client The client that has authenticated successfully.
 @param userID The user identifier in Identity Provider from which the Identity Token was obtained. Typically the primary key, username, or email
    of the user that was authenticated.
 */
- (void)layerClient:(LYRClient *)client didAuthenticateAsUserID:(NSString *)userID;

/**
 @abstract Tells the delegate that a client has been deauthenticated.
 @discussion The client may become deauthenticated either by an explicit call to `deauthenticateWithCompletion:` or by encountering an authentication challenge.
 @param client The client that was deauthenticated.
 */
- (void)layerClientDidDeauthenticate:(LYRClient *)client;

/**
 @abstract Tells the delegate that a client has finished synchronization and applied a set of changes.
 @param client The client that received the changes.
 @param changes An array of `NSDictionary` objects, each one describing a change.
 */
- (void)layerClient:(LYRClient *)client didFinishSynchronizationWithChanges:(NSArray *)changes __deprecated;

/**
 @abstract Tells the delegate the client encountered an error during synchronization.
 @param client The client that failed synchronization.
 @param error An error describing the nature of the sync failure.
 */
- (void)layerClient:(LYRClient *)client didFailSynchronizationWithError:(NSError *)error __deprecated;

/**
 @abstract Tells the delegate that objects associated with the client have changed due to local mutation or synchronization activities.
 @param client The client that received the changes.
 @param changes An array of `LYRObjectChange` objects, each one describing a change.
 @see LYRConstants.h
 */
- (void)layerClient:(LYRClient *)client objectsDidChange:(NSArray *)changes;

/**
 @abstract Tells the delegate that an operation encountered an error during a local mutation or synchronization activity.
 @param client The client that failed the operation.
 @param error An error describing the nature of the operation failure.
 */
- (void)layerClient:(LYRClient *)client didFailOperationWithError:(NSError *)error;

/**
 @abstract Tells the delegate that a content transfer will begin.
 @param client The client that will begin the content transfer.
 @param contentTransferType Type enum representing the content transfer type.
 @param object Object whose content will begin transfering.
 @param progress The `LYRProgress` instance that tracks the progress of the object.
 */
- (void)layerClient:(LYRClient *)client willBeginContentTransfer:(LYRContentTransferType)contentTransferType ofObject:(id)object withProgress:(LYRProgress *)progress;

/**
 @abstract Tells the delegate that a content transfer has finished.
 @param client The client that will begin the content transfer.
 @param contentTransferType Type enum representing the content transfer type.
 @param object Object whose content did finish transfering.
 */
- (void)layerClient:(LYRClient *)client didFinishContentTransfer:(LYRContentTransferType)contentTransferType ofObject:(id)object;

@end

/**
 @abstract The `LYRClient` class is the primary interface for developer interaction with the Layer platform.
 @discussion The `LYRClient` class and related classes provide an API for rich messaging via the Layer platform. This API supports the exchange of multi-part Messages within multi-user Conversations and advanced features such
 as mutation of the participants, deletion of messages or the entire conversation, and the attachment of free-form user defined metadata. The API is sychronization based, fully supporting offline usage and providing full access
 to the history of messages across devices.
 */
@interface LYRClient : NSObject

///----------------------------
/// @name Initializing a Client
///----------------------------

/**
 @abstract Creates and returns a new Layer client instance.
 @param appID An app id url obtained from the Layer Developer Portal. https://developer.layer.com/projects
 @return Returns a newly created Layer client object, or `nil` in the case the client cannot not be initialized due to file protection.
 @warning Throws `NSInternalInconsistencyException` when creating another Layer Client instance with the same `appID` value under the same process (application).
 However multiple instances of Layer Client with the same `appID` are allowed if running the code under Unit Tests.  Make sure to initialize the client when the 
 file access is available if the app uses NSFileProtection.
 */
+ (instancetype)clientWithAppID:(NSURL *)appID;

/**
 @abstract The object that acts as the delegate of the receiving client.
 */
@property (nonatomic, weak) id<LYRClientDelegate> delegate;

/**
 @abstract The app key.
 */
@property (nonatomic, copy, readonly) NSURL *appID;

///--------------------------------
/// @name Managing Connection State
///--------------------------------

/**
 @abstract Signals the receiver to establish a network connection and initiate synchronization.
 @discussion If the client has previously established an authenticated identity then the session is resumed and synchronization is activated.
 @param completion An optional block to be executed once connection state is determined. The block has no return value and accepts two arguments: a Boolean value indicating if the connection was made 
 successfully and an error object that, upon failure, indicates the reason that connection was unsuccessful.
*/
- (void)connectWithCompletion:(void (^)(BOOL success, NSError *error))completion;

/**
 @abstract Signals the receiver to end the established network connection.
 */
- (void)disconnect;

/**
 @abstract Returns a Boolean value that indicates if the client is in the process of connecting to Layer.
 */
@property (nonatomic, readonly) BOOL isConnecting;

/**
 @abstract Returns a Boolean value that indicates if the client is connected to Layer.
 */
@property (nonatomic, readonly) BOOL isConnected;

///--------------------------
/// @name User Authentication
///--------------------------

/**
 @abstract Returns a string object specifying the user ID of the currently authenticated user or `nil` if the client is not authenticated.
 @discussion A client is considered authenticated if it has previously established identity via the submission of an identity token
 and the token has not yet expired. The Layer server may at any time issue an authentication challenge and deauthenticate the client.
*/
@property (nonatomic, readonly) NSString *authenticatedUserID;

/**
 @abstract Requests an authentication nonce from Layer.
 @discussion Authenticating a Layer client requires that an Identity Token be obtained from a remote backend application that has been designated to act as an
 Identity Provider on behalf of your application. When requesting an Identity Token from a provider, you are required to provide a nonce value that will be included
 in the cryptographically signed data that comprises the Identity Token. This method asynchronously requests such a nonce value from Layer.
 @warning Nonce values can be issued by Layer at any time in the form of an authentication challenge. You must be prepared to handle server issued nonces as well as those
 explicitly requested by a call to `requestAuthenticationNonceWithCompletion:`.
 @param completion A block to be called upon completion of the asynchronous request for a nonce. The block takes two parameters: the nonce value that was obtained (or `nil`
 in the case of failure) and an error object that upon failure describes the nature of the failure.
 @see LYRClientDelegate#layerClient:didReceiveAuthenticationChallengeWithNonce:
 */
- (void)requestAuthenticationNonceWithCompletion:(void (^)(NSString *nonce, NSError *error))completion;

/**
 @abstract Authenticates the client by submitting an Identity Token to Layer for evaluation.
 @discussion Authenticating a Layer client requires the submission of an Identity Token from a remote backend application that has been designated to act as an
 Identity Provider on behalf of your application. The Identity Token is a JSON Web Signature (JWS) string that encodes a cryptographically signed set of claims
 about the identity of a Layer client. An Identity Token must be obtained from your provider via an application defined mechanism (most commonly a JSON over HTTP
 request). Once an Identity Token has been obtained, it must be submitted to Layer via this method in ordr to authenticate the client and begin utilizing communication
 services. Upon successful authentication, the client remains in an authenticated state until explicitly deauthenticated by a call to `deauthenticateWithCompletion:` or
 via a server-issued authentication challenge.
 @param identityToken A string object encoding a JSON Web Signature that asserts a set of claims about the identity of the client. Must be obtained from a remote identity
 provider and include a nonce value that was previously obtained by a call to `requestAuthenticationNonceWithCompletion:` or via a server initiated authentication challenge.
 @param completion A block to be called upon completion of the asynchronous request for authentication. The block takes two parameters: a string encoding the remote user ID that
 was authenticated (or `nil` if authentication was unsuccessful) and an error object that upon failure describes the nature of the failure.
 @see http://tools.ietf.org/html/draft-ietf-jose-json-web-signature-25
 */
- (void)authenticateWithIdentityToken:(NSString *)identityToken completion:(void (^)(NSString *authenticatedUserID, NSError *error))completion;

/**
 @abstract Deauthenticates the client, disposing of any previously established user identity and disallowing access to the Layer communication services until a new identity is established. All existing messaging data is purged from the database.
 @param completion A block to be executed when the deauthentication operation has completed. The block has no return value and has two arguments: a Boolean value indicating if deauthentication was successful and an error describing the failure if it was not.
 */
- (void)deauthenticateWithCompletion:(void (^)(BOOL success, NSError *error))completion;

///-------------------------------------------------------
/// @name Registering For and Receiving Push Notifications
///-------------------------------------------------------

/**
 @abstract Tells the receiver to update the device token used to deliver Push Notifications to the current device via the Apple Push Notification Service.
 @param deviceToken An `NSData` object containing the device token or `nil`.
 @param error A reference to an `NSError` object that will contain error information in case the action was not successful.
 @return A Boolean value that determines whether the action was successful.
 @discussion The device token is expected to be either an `NSData` object returned by the method `application:didRegisterForRemoteNotificationsWithDeviceToken:` or `nil`. If an `NSData` object is provided, the device token is cached locally and is sent to Layer cloud automatically when the connection is established. If `nil`, all device tokens that are associated with the currently authenticated and the current device will be deleted. Device tokens associated with other devices will not be deleted.
 */
- (BOOL)updateRemoteNotificationDeviceToken:(NSData *)deviceToken error:(NSError **)error;

/**
 @abstract Inspects an incoming push notification and synchronizes the client if it was sent by Layer.
 @param userInfo The user info dictionary received from the UIApplicaton delegate method application:didReceiveRemoteNotification:fetchCompletionHandler:'s `userInfo` parameter.
 @param completion The block that will be called once Layer has successfully downloaded new data associated with the `userInfo` dictionary passed in. It is your responsibility to call the UIApplication delegate method's fetch completion handler with an appropriate fetch result for the given `changes`. Note that this block is only called if the method returns `YES`.
 @return A Boolean value that determines whether the push was handled. Will be `NO` if this was not a push notification meant for Layer and the completion block will not be called.
 @note The receiver must be authenticated else a warning will be logged and `NO` will be returned. The completion is only invoked if the return value is `YES`.
 */
- (BOOL)synchronizeWithRemoteNotification:(NSDictionary *)userInfo completion:(void(^)(NSArray *changes, NSError *error))completion;

///----------------------------------------------
/// @name Creating new Conversations and Messages
///----------------------------------------------

/**
 @abstract Creates a new Conversation with the given set of participants.
 @discussion This method will create a new `LYRConversation` instance, creating new message instances with a new `LYRConversation` object instance and sending them will also result in creation of a new conversation for other participants. If you wish to ensure that only one Conversation exists for a set of participants then set the value for the `LYRConversationOptionsDistinctByParticipantsKey` key to true in the `options` parameter.
 @param participants A set of participants with which to initialize the new Conversation.
 @param options A dictionary of options to apply to the conversation.
 @param error A pointer to an error that upon failure is set to an error object describing why execution failed.
 @return The newly created Conversation or `nil` if an attempt is made to create a conversation with a distinct participants list, but one already exists. The existing conversation will be set as the value for the `LYRExistingDistinctConversationKey` in the `userInfo` dictionary of the error parameter.
 */
- (LYRConversation *)newConversationWithParticipants:(NSSet *)participants options:(NSDictionary *)options error:(NSError **)error;

/**
 @abstract Creates and returns a new message with the given set of message parts.
 @discussion This method will allow a maximum of 1000 parts per message.
 @param messageParts An array of `LYRMessagePart` objects specifying the content of the message. Cannot be `nil` or empty.
 @param options A dictionary of options to apply to the message.
 @return A new message that is ready to be sent.
 @raises NSInvalidArgumentException Raised if `conversation` is `nil` or `messageParts` is empty.
 */
- (LYRMessage *)newMessageWithParts:(NSArray *)messageParts options:(NSDictionary *)options error:(NSError **)error;

///---------------
/// @name Querying
///---------------

/**
 @abstract Executes the given query and returns an ordered set of results.
 @param query The query to execute. Cannot be `nil`.
 @param error A pointer to an error that upon failure is set to an error object describing why execution failed.
 @return An ordered set of query results or `nil` if an error occurred.
 */
- (NSOrderedSet *)executeQuery:(LYRQuery *)query error:(NSError **)error;

/**
 @abstract Executes the given query asynchronously and passes the results back in a completion block.
 @param query The query to execute. Cannot be `nil`.
 @param completion The block that will be passed once Layer has executed the query.  If successful the `resultSet` will have the results, and if unsuccessful `error` will contain the specific query error.
 */
- (void)executeQuery:(LYRQuery *)query completion:(void (^)(NSOrderedSet *resultSet, NSError *error))completion;

/**
 @abstract Executes the given query and returns a count of the number of results.
 @param query The query to execute. Cannot be `nil`.
 @param error A pointer to an error that upon failure is set to an error object describing why execution failed.
 @return A count of the number of results or `NSUIntegerMax` if an error occurred.
 */
- (NSUInteger)countForQuery:(LYRQuery *)query error:(NSError **)error;

/**
 @abstract Executes the given query asynchronously and ppasses the result count and error back in a completion block.
 @param query The query to execute. Cannot be `nil`.
 @param completion The block that will be passed once Layer has executed the query.  If successful the `count` will have the count requested in the query, and if unsuccessful `error` will contain the specific query error.
 */
- (void)countForQuery:(LYRQuery *)query completion:(void (^)(NSUInteger count, NSError *error))completion;

/**
 @abstract Creates and returns a new query controller with the given query.
 @param query The query to create a controller with.
 @param error A pointer to an error that upon failure is set to a `NSError` object describing why query controller creation failed.
 @return A newly created query controller.
 */
- (LYRQueryController *)queryControllerWithQuery:(LYRQuery *)query error:(NSError **)error;

///-------------------------------
/// @name Marking Messages as Read
///-------------------------------

/**
 @abstract Marks a set of messages as being read by the current user. If `nil` the operation will mark all unread messsages as being read by the current user.
 @discussion The operation will ignore messages that have previously been marked as read.
 @param messages A set of messages to be marked as read or `nil`.
 @param error A pointer to an error object that, upon failure, will be set to an error describing why the message could not be sent.
 @return `YES` if the messages were marked as read or `NO` if the operation failed.
 */
- (BOOL)markMessagesAsRead:(NSSet *)messages error:(NSError **)error;

///---------------
/// @name Policies
///---------------

/**
 @abstract Returns the ordered set of `LYRPolicy` objects governing the behavior of the client.
 @discussion
 */
@property (nonatomic, readonly) NSOrderedSet *policies;

/**
 @abstract Validates the given policy to determine if it represents a valid configuration that can be added to the receiver.
 @param policy The policy to validate.
 @param error A pointer to an error that upon failure is set to an error object describing why validation was unsuccessful.
 @return A Boolean value that indicates if the given policy is valid or not.
 */
- (BOOL)validatePolicy:(LYRPolicy *)policy error:(NSError **)error;

/**
 @abstract Adds the given policy to the receiver.
 @param policy The policy to be added to the client.
 @param error A pointer to an error that upon failure is set to an error object describing the policy could not be added.
 */
- (BOOL)addPolicy:(LYRPolicy *)policy error:(NSError **)error;

/**
 @abstract Inserts the given policy in the receiver's policy set at the specified index.
 @param policy The policy to be added to the client.
 @param index The index at which to insert the policy.
 @param error A pointer to an error that upon failure is set to an error object describing the policy could not be added.
 */
- (BOOL)insertPolicy:(LYRPolicy *)policy atIndex:(NSUInteger)index error:(NSError **)error;

/**
 @abstract Removes the specified policy from the receiver.
 @param policy The policy to be removed from the client.
 @param error A pointer to an error that upon failure is set to an error object describing the policy could not be added.
 @return A Boolean value that indicates if the given policy was removed.
 */
- (BOOL)removePolicy:(LYRPolicy *)policy error:(NSError **)error;

///---------------------------------
/// @name Managing Content Transfers
///---------------------------------

/**
 @abstract Specifies the maximum amount of disk space (in bytes) that may be utilized for storing downloaded message part content. A value of zero (the default) indicates that
 an unlimited amount of disk space may be utilized.
 @discussion Once current disk utilization of downloaded message part content exceeds the maximum capacity the system will delete content on a least recently used basis until
 the total utilization is 80% of the configured disk capacity. Note that auto-downloaded content that gets deleted is not automatically downloaded again.
 */
@property (nonatomic, assign) LYRSize diskCapacity;

/**
 @abstract Returns the amount of disk space currently being utilized for the storage of downloaded message part content.
 @note The property is not updated in real-time, it may time some amount of time for it to update.
 @discussion Utilization may periodically peak above the configured `diskCapacity` while synchronization or downloads are in progress, but will be rebalanced once all operations
 have completed.
 */
@property (nonatomic, readonly) LYRSize currentDiskUtilization;

/**
 @abstract A Boolean value that determines whether or not the client will execute content transfers while the application is in a background state.
 @discussion In order to utilize background transfers your application must implement the `UIApplicateDelegate` method `application:handleEventsForBackgroundURLSession:completionHandler:` and forward calls to the `LYRClient` method `handleBackgroundContentTransfersForSessionWithIdentifier:completion:`.
 @note Changes to this flag will not affect any transfers already in progress.
 */
@property (nonatomic) BOOL backgroundContentTransferEnabled;

/**
 @abstract Handles content transfer events from iOS and synchronizes the client if required.
 @param sessionIdentifier URL session identifier handed by the `application:handleEventsForBackgroundURLSession:completionHandler:`.
 @param completion The block that will be called once Layer has successfully handled content transfers. It is your responsibility to call the UIApplication delegate method's completion handler. Note that this block is only called if the method returns `YES`.
 @return A Boolean value that indicates whether or not the client handled the content transfers for the given background session identifier. `YES` will be returned if the session identifier refers to a background session that was created by the Layer client, else `NO`.
 @note The receiver must be authenticated else a warning will be logged and `NO` will be returned. The completion is only invoked if the return value is `YES`.
 */
- (BOOL)handleBackgroundContentTransfersForSession:(NSString *)sessionIdentifier completion:(void(^)(NSArray *changes, NSError *error))completion;

/**
 @abstract Configures the set of MIME Types for `LYRMessagePart` objects that will be automatically downloaded upon synchronization.
 @discussion A value of `nil` indicates that all content is to be downloaded automatically and an empty `NSSet` indicates that no content should be. The default value is a set containing the MIME Type @"text/plain". Message parts belonging to latest messages will be auto-downloaded first.
 */
@property (nonatomic) NSSet *autodownloadMIMETypes;

/**
 @abstract Configures the maximum size (in bytes) for `LYRMessagePart` objects that will be automatically downloaded upon synchronization.
 @discussion The default value is `0`.
 */
@property (nonatomic) LYRSize autodownloadMaximumContentSize;

///----------------
/// @name Debugging
///----------------

/**
 @abstract Captures a debug snapshot of the current state of the Layer powered application and persists it to the file system.
 @param completion A block to be called upon completion of the asynchronous request for a debug snapshot. The block takes one parameter: an `NSURL` location of the snapshot on the file system.
 @discussion The debug snapshot is a zip file containing the following: 1. A JSON dump of diagnostic information about the `LYRClient` 2. A copy of the local database, 3. A copy of any accumulated log files.
 */
- (void)captureDebugSnapshotWithCompletion:(void(^)(NSURL *snapshotPath, NSError *error))completion;

/**
 @abstract When `YES`, `LayerKit` will log detailed debugging information to both the XCode debugger and the file system.
 @discussion When debugging is enabled, all components will begin to synchronously log detailed information to both the file system and the debugger.
 */
@property (nonatomic) BOOL debuggingEnabled;

/**
 @abstract Configures the log level for the specified component
 @param level The log level to be set for the component.
 @param component The component to configure.
 */
- (void)setLogLevel:(LYRLogLevel)level forComponent:(LYRLogComponent)component;

@end

///////////////////////////////////////////////////////////////////////////////////////

@interface LYRClient (Deprecated)

// DEPRECATED: Use `LYRConversation`'s `addParticipants:error:` instead.
- (BOOL)addParticipants:(NSSet *)participants toConversation:(LYRConversation *)conversation error:(NSError **)error __deprecated;

// DEPRECATED: Use `LYRConversation`'s `removeParticipants:error:` instead.
- (BOOL)removeParticipants:(NSSet *)participants fromConversation:(LYRConversation *)conversation error:(NSError **)error __deprecated;

// DEPRECATED: Use `LYRConversation`'s `sendMessage:error:` instead.
- (BOOL)sendMessage:(LYRMessage *)message error:(NSError **)error __deprecated;

// DEPRECATED: Use `LYRMessage`'s `markAsRead:` instead.
- (BOOL)markMessageAsRead:(LYRMessage *)message error:(NSError **)error __deprecated;

// DEPRECATED: Use `LYRMessage`'s `delete:error:` instead.
- (BOOL)deleteMessage:(LYRMessage *)message mode:(LYRDeletionMode)deletionMode error:(NSError **)error __deprecated;

// DEPRECATED: Use `LYRMessage`'s `delete:error:` instead.
- (BOOL)deleteMessage:(LYRMessage *)message error:(NSError **)error __deprecated;

// DEPRECATED: Use `LYRConversation`'s `delete:error:` instead.
- (BOOL)deleteConversation:(LYRConversation *)conversation mode:(LYRDeletionMode)deletionMode error:(NSError **)error __deprecated;

// DEPRECATED: Use `LYRConversation`'s `delete:error:` instead.
- (BOOL)deleteConversation:(LYRConversation *)conversation error:(NSError **)error __deprecated;

// DEPRECATED: Use `newMessageWithParts:options:error:` instead.
- (BOOL)setMetadata:(NSDictionary *)metadata onObject:(id)object __deprecated;

// DEPRECATED: Use `LYRConversation`'s `sendTypingIndicator:` instead.
- (void)sendTypingIndicator:(LYRTypingIndicator)typingIndicator toConversation:(LYRConversation *)conversation __deprecated;

/*
 DEPRECATED: Use the following query code instead:
 
    NSError *error = nil;
    LYRQuery *query = [LYRQuery queryWithClass:[LYRConversation class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"identifier" operator:LYRPredicateOperatorIsEqualTo value:identifier];
    query.limit = 1;
    LYRConversation *conversation = [[client executeQuery:query error:&error] firstObject];
 */
- (LYRConversation *)conversationForIdentifier:(NSURL *)identifier __deprecated;

/*
 DEPRECATED: Use the following query code instead:
 
    NSError *error = nil;
    LYRQuery *query = [LYRQuery queryWithClass:[LYRConversation class]];
    if (conversationIdentifiers != nil) {
       query.predicate = [LYRPredicate predicateWithProperty:@"identifier" operator:LYRPredicateOperatorIsIn value:conversationIdentifiers];
    }
    NSSet *conversations = [[client executeQuery:query error:&error] set];
 */
- (NSSet *)conversationsForIdentifiers:(NSSet *)conversationIdentifiers __deprecated;

/*
 DEPRECATED: Use the following query code instead:
 
    NSError *error = nil;
    LYRQuery *query = [LYRQuery queryWithClass:[LYRConversation class]];
    NSSet *participantsIncludingAuthenticatedUser = [participants setByAddingObject:self.authenticatedUserID];
    query.predicate = [LYRPredicate predicateWithProperty:@"participants" operator:LYRPredicateOperatorIsEqualTo value:participantsIncludingAuthenticatedUser];
    NSSet *conversations = [[client executeQuery:query error:&error] set];
 */
- (NSSet *)conversationsForParticipants:(NSSet *)participants __deprecated;

/*
 DEPRECATED: Use the following query code instead:
 
    NSError *error = nil;
    LYRQuery *query = [LYRQuery queryWithClass:[LYRMessage class]];
    if (messageIdentifiers != nil) {
    query.predicate = [LYRPredicate predicateWithProperty:@"identifier" operator:LYRPredicateOperatorIsIn value:messageIdentifiers];
    }
    return [[client executeQuery:query error:&error] set];
 */
- (NSSet *)messagesForIdentifiers:(NSSet *)messageIdentifiers __deprecated;

/*
 DEPRECATED: Use the following query code instead:
 
    NSError *error = nil;
    LYRQuery *query = [LYRQuery queryWithClass:[LYRMessage class]];
    if (conversation) {
        query.predicate = [LYRPredicate predicateWithProperty:@"conversation" operator:LYRPredicateOperatorIsEqualTo value:conversation];
    }
    query.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"position" ascending:YES]];
    return [client executeQuery:query error:&error];
 */
- (NSOrderedSet *)messagesForConversation:(LYRConversation *)conversation __deprecated;

/*
 DEPRECATED: Use the following query code instead:
 
    NSError *error = nil;
    LYRQuery *query = [LYRQuery queryWithClass:[LYRConversation class]];
    query.predicate = [LYRPredicate predicateWithProperty:@"hasUnreadMessages" operator:LYRPredicateOperatorIsEqualTo value:@(YES)];
    return [client countForQuery:query error:&error];
 */
- (NSUInteger)countOfConversationsWithUnreadMessages __deprecated;

/*
 DEPRECATED: Use the following query code instead:
 
    NSError *error = nil;
    LYRQuery *query = [LYRQuery queryWithClass:[LYRMessage class]];
    if (conversation) {
        LYRPredicate *conversationIsEqualPredicate = [LYRPredicate predicateWithProperty:@"conversation" operator:LYRPredicateOperatorIsEqualTo value:conversation];
        LYRPredicate *unreadIsEqualPredicate = [LYRPredicate predicateWithProperty:@"isUnread" operator:LYRPredicateOperatorIsEqualTo value:@(YES)];
        query.predicate = [LYRCompoundPredicate compoundPredicateWithType:LYRCompoundPredicateTypeAnd subpredicates:@[conversationIsEqualPredicate, unreadIsEqualPredicate]];
    } else {
        query.predicate = [LYRPredicate predicateWithProperty:@"isUnread" operator:LYRPredicateOperatorIsEqualTo value:@(YES)];
    }
    return [client countForQuery:query error:&error];
 */
- (NSUInteger)countOfUnreadMessagesInConversation:(LYRConversation *)conversation __deprecated;

// DEPRECATED: Use `LYRClient`'s `queryControllerWithQuery:error:` instead.
- (LYRQueryController *)queryControllerWithQuery:(LYRQuery *)query __deprecated;

@end

@interface LYRClient (ObjectIdentifierMigration)

/**
 @abstract Returns the canonical object identifier for a given identifier.
 @discussion This method enables the migration of object identifiers created by LayerKit < v0.9.0 to the canonical
 format emitted by v0.9.0 and higher clients. If the given identifier already is a new style identifier, then it is returned. If
 the input identifier is a legacy identifier, then the canonical identifier is computed and returned. If no conversation or message can
 be found by treating the identifier as a legacy or canonical identifier then `nil` is returned (typically indicating that the content has
 not yet been synchronized).
 @param identifier The object identifier for which to return the canonical identifier.
 @return The canonical object identifier for the given input identifier or `nil` if none could be computed.
 */
- (NSURL *)canonicalObjectIdentifierForIdentifier:(NSURL *)identifier;

@end
