//
//  LYRConstants.h
//  LayerKit
//
//  Created by Blake Watters on 7/13/2014
//  Copyright (c) 2014 Layer. All rights reserved.
//

///---------------
/// @name Typedefs
///---------------

/**
 @abstract A type representing an absolute logical position of an object within a sequence.
 */
typedef uint64_t LYRPosition;
#define LYRPositionNotDefined UINT64_MAX

/**
 @abstract A type representing a content size in bytes.
 */
typedef uint64_t LYRSize;
#define LYRSizeNotDefined UINT64_MAX

/**
 @abstract The `LYRDeletionMode` enumeration defines the available modes for deleting content.
 */
typedef NS_ENUM(NSUInteger, LYRDeletionMode) {
    /**
     @abstract Content is deleted from the current device only. This is an unsynchronized delete and content
     will be synchronized to other devices and will be resynchronized if the client is deauthenticated.
     */
    LYRDeletionModeLocal            = 0,
    
    /**
     @abstract Content is deleted from all devices of all participants. This is a synchronized, permanent delete
     that results in content being deleted from the devices of existing users who have previously synchronized and
     makes the content unavailable for synchronization to new participants or devices.
     **/
    LYRDeletionModeAllParticipants  = 2
};

///---------------------
/// @name Object Changes
///---------------------

typedef NS_ENUM(NSInteger, LYRObjectChangeType) {
	LYRObjectChangeTypeCreate   = 0,
	LYRObjectChangeTypeUpdate   = 1,
	LYRObjectChangeTypeDelete   = 2
};

///-----------------------
/// @name Typing Indicator
///-----------------------

/**
 @abstract The `LYRTypingIndicator` enumeration describes the states of a typing status of a participant in a conversation.
 */
typedef NS_ENUM(NSUInteger, LYRTypingIndicator) {
    LYRTypingDidBegin   = 0,
    LYRTypingDidPause   = 1,
    LYRTypingDidFinish  = 2
};

///-----------------------
/// @name Content Transfer
///-----------------------

/**
 @abstract The `LYRContentTransferType` values describe the type of a transfer. Used when LYRClient calls to the delegate via `layerClient:willBeginContentTransfer:ofObject:withProgress` and `layerClient:didFinishContentTransfer:ofObject:` methods.
 */
typedef NS_ENUM(NSInteger, LYRContentTransferType) {
    LYRContentTransferTypeDownload              = 0,
    LYRContentTransferTypeUpload                = 1
};

///////////////////////////////////////////////////////////////////////////////////////

/*
 DEPRECATED: Use the `type` property on `LYRObjectChange` instead.
 */
extern NSString *const LYRObjectChangeTypeKey __deprecated;

/*
 DEPRECATED: Use the `object` property on `LYRObjectChange` instead.
 */
extern NSString *const LYRObjectChangeObjectKey __deprecated;

/*
 DEPRECATED: Use the `property` property on `LYRObjectChange` instead.
 */
extern NSString *const LYRObjectChangePropertyKey __deprecated;

/*
 DEPRECATED: Use the `beforeValue` property on `LYRObjectChange` instead.
 */
extern NSString *const LYRObjectChangeOldValueKey __deprecated;

/*
 DEPRECATED: Use the `afterValue` property on `LYRObjectChange` instead.
 */
extern NSString *const LYRObjectChangeNewValueKey __deprecated;

