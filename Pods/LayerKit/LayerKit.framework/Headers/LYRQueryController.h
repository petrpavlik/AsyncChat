//
//  LYRQueryController.h
//  LayerKit
//
//  Created by Blake Watters on 11/05/14.
//  Copyright (c) 2014 Layer. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LYRQuery;
@protocol LYRQueryControllerDelegate, LYRQueryable;

/**
 @abstract The `LYRQueryController` class provides an interface for driving the user interface of a `UITableView` or `UICollectionView` directly from a `LYRQuery` object.
 */
@interface LYRQueryController : NSObject

///--------------------------
/// @name Accessing the Query
///--------------------------

/**
 @abstract Returns the query of the receiver.
 */
@property (nonatomic, readonly) LYRQuery *query;

///---------------------------------
/// @name Configuring Update Elision
///---------------------------------

/**
 @abstract Configures the set of properties on the queried model class for which `LYRQueryControllerChangeTypeUpdate` changes will be emitted. The default value is `nil`, which means that all property changes will generate update notifications to the delegate.
 @discussion The set of updatable properties is used to enhance performance by suppressing the delivery of uninteresting update notifications to the delegate and the subsequent reloading of table or collection view cells. For example, given a collection view that is rendering `LYRMessage` objects but does not include read or delivery receipt status on the cell, the developer may wish to limit the updatable properties to `isSent` and `isUnread` so that the UI does not refresh as delivery and read receipts are synchronized from other participants of the conversation. A value of `nil` indicates that no filtering is to be applied and any update to an object in the collection will generate an update callback. An empty set disables all update notifications.
 */
@property (nonatomic) NSSet *updatableProperties;

///-------------------------
/// @name Pagination Support
///-------------------------

/**
 @abstract Configures a pagination window for limiting the number of objects that are exposed to the `UITableView` or `UICollectionView` object driven via the query controller.
 The default value is `NSIntegerMax`, which indicates that no pagination window is to be applied.
 @discussion The pagination window is used to improve the performance of table or collection view objects that utilize a query controller as the model for their associated data source.
 When a pagination window is applied, the query controller will expose a subset of the total set of objects that match the query to the consumer. The window is expressed as a signed integer,
 where a positive value indicates a window that originates from index 0 (or the "top" of the data set) and covers the specified number of objects. In other words, given a query that matches
 100 objects, a pagination window of 25 would display objects from index 0 to 24. Additional objects can be paged into the view on demand by expanding the window size. The pagination window can
 also be expressed as a negative integer, in which case the window originates from the maximum index of the object collection (or the "bottom" of the data set) and extends backward. In the example
 of a collection of 100 objects, a pagination window of -25 would display the objects from index 74 to 99. Negative pagination windows are useful when displaying a paginated collection of messages
 where the most recent messages are displayed on the bottom of the view and the chronologically older messages are displayed at the top.
 
 As the user scrolls to the top or taps a "Load More" button, the window can be expanded to performantly load additional messages into the collection. The pagination window can expand as objects are added to the result set due to incoming events.
 */
@property (nonatomic) NSInteger paginationWindow;


/**
 @abstract Returns the total number of objects in the query result set without pagination.
 @return The number of objects in the result set, without pagination constraints.
 */
@property (nonatomic, readonly) NSUInteger totalNumberOfObjects;

///-----------------------------
/// @name Accessing the Delegate
///-----------------------------

/**
 @abstract Accesses the receiver's delegate.
 */
@property (nonatomic, weak) id<LYRQueryControllerDelegate> delegate;

///-----------------------------------------
/// @name Counting Objects in the Result Set
///-----------------------------------------

/**
 @abstract Returns the number of sections in the result set.
 @return The number of sections in the receiver's result set.
 */
- (NSUInteger)numberOfSections;

/**
 @abstract Returns the number of objects in the given section in the result set.
 @param section The section to return the number of objects for.
 @return The number of objects in the specified section of the result set.
 */
- (NSUInteger)numberOfObjectsInSection:(NSUInteger)section;

/**
 @abstract Returns the total number of objects in the result set.
 @return The number of objects in the result set that the controller has loaded based on `paginationWindow`.
 */
- (NSUInteger)count;

///----------------------------------------
/// @name Accessing Objects and Index Paths
///----------------------------------------

/**
 @abstract Returns the object for the given index path from the result set.
 @param indexPath The index path for the object to retrieve.
 @return The object at the specified index or `nil` if none could be found.
 */
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

/**
 @abstract Returns the index path for the given object in the result set.
 @param object The object to retrieve the index path for.
 @return The index path for the given object or `nil` if it does not exist in the result set.
 */
- (NSIndexPath *)indexPathForObject:(id<LYRQueryable>)object;

/**
 @abstract Returns a dictionary mapping the given set of object identifiers to the `NSIndexPath` values that indicate 
 where in the query controller's result set the corresponding objects appear. Any object identifiers that are not in
 the result set (or are outside the pagination window) will not have an entry in the dictionary returned.
 @param objectIdentifiers The set of object identifiers to look up within the query controller.
 @return A dictionary mapping the object identifiers that are part of the query controller results to the index path that appear at.
 */
- (NSDictionary *)indexPathsForObjectsWithIdentifiers:(NSSet *)objectIdentifiers;

///--------------------------
/// @name Executing the Query
///--------------------------

/**
 @abstract Executes the query and loads a result set into the receiver.
 @param error A pointer to an error object that upon failure is set to an error object that describes 
 the nature of the failure.
 @return A Boolean value that indicates if execution of the query was successful.
 */
- (BOOL)execute:(NSError **)error;

/**
 @abstract Executes the query asynchronously and loads a result and error in a completion block.
 @param completion A block that passes back a BOOL if the execution of the query was successful, and an associated error object if there
 was an error during execution.
 */
- (void)executeWithCompletion:(void (^)(BOOL success, NSError *error))completion;

@end

/**
 @abstract The `LYRQueryControllerChangeType` is an enumerated value that specifies the type of change occurring in the
 result set of an `LYRQueryController` object.
 */
typedef NS_ENUM(NSUInteger, LYRQueryControllerChangeType) {
    /**
     @abstract An object is being inserted into the result set.
     */
    LYRQueryControllerChangeTypeInsert 	= 1,
    
    /**
     @abstract An object is being deleted from the result set.
     */
    LYRQueryControllerChangeTypeDelete 	= 2,
    
    /**
     @abstract An object is being moved within the result set.
     */
    LYRQueryControllerChangeTypeMove 	= 3,
    
    /**
     @abstract An object is being deleted from the result set.
     */
    LYRQueryControllerChangeTypeUpdate 	= 4
};

/**
 @abstract The `LYRQueryControllerDelegate` protocol is adopted by objects that wish to act as the delegate for a query controller.
 */
@protocol LYRQueryControllerDelegate <NSObject>

@optional

/**
 @abstract Tells the delegate that the result set of query controller is about to change.
 @param The query controller that is changing.
 */
- (void)queryControllerWillChangeContent:(LYRQueryController *)queryController;

/**
 @abstract Tells the delegate that the result set of query controller has changed.
 @param The query controller that has changed.
 */
- (void)queryControllerDidChangeContent:(LYRQueryController *)queryController;

/**
 @abstract Tells the delegate that a particular object in the result set of query controller has changed.
 @param The query controller that is changing.
 @param object The object that has changed in the result set.
 @param indexPath The index path of the object or `nil` if the change is an insert.
 @param type An enumerated value that specifies the type of change that is occurring.
 @param newIndexPath The new index path for the object or `nil` if the change is an update or delete.
 */
- (void)queryController:(LYRQueryController *)controller didChangeObject:(id)object atIndexPath:(NSIndexPath *)indexPath forChangeType:(LYRQueryControllerChangeType)type newIndexPath:(NSIndexPath *)newIndexPath;

@end
