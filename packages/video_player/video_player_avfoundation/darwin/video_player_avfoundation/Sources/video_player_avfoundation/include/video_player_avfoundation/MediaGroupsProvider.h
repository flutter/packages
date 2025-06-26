#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * @brief A block called upon completion of fetching media groups.
 * @param groups An array of AVMediaSelectionGroup objects, or nil if an error occurred.
 * @param error An error object if the operation failed, otherwise nil.
 */
typedef void (^MediaGroupsCompletionHandler)(NSArray<AVMediaSelectionGroup *> *_Nullable groups,
                                             NSError *_Nullable error);

/**
 * @brief Encapsulates the logic for asynchronously fetching all playable
 * media selection groups from an AVAsset.
 */
@interface MediaGroupsProvider : NSObject

/**
 * Asynchronously fetches all available and playable media selection groups from the given asset.
 *
 * @param asset The AVAsset to process.
 * @param completionHandler The block to be executed when the operation is complete.
 * This handler will be called on the main thread.
 */
- (void)fetchMediaGroupsFromAsset:(AVAsset *)asset
                       completion:(MediaGroupsCompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END