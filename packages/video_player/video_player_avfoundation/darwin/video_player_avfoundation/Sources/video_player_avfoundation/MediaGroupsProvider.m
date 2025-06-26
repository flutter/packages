#import "MediaGroupsProvider.h"

static NSString *const AVAssetKeyAvailableMediaCharacteristics =
    @"availableMediaCharacteristicsWithMediaSelectionOptions";

@implementation MediaGroupsProvider

- (void)fetchMediaGroupsFromAsset:(AVAsset *)asset
                       completion:(MediaGroupsCompletionHandler)completionHandler {
  NSArray<NSString *> *keysToLoad = @[ AVAssetKeyAvailableMediaCharacteristics ];
   

  [asset
      loadValuesAsynchronouslyForKeys:keysToLoad
                    completionHandler:^{
                      NSError *error = nil;
                      AVKeyValueStatus status =
                          [asset statusOfValueForKey:AVAssetKeyAvailableMediaCharacteristics
                                               error:&error];
                      if (status != AVKeyValueStatusLoaded || error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completionHandler(nil, error);
                        });
                        return;
                      }

                      NSMutableArray<AVMediaSelectionGroup *> *loadedGroups =
                          [NSMutableArray array];
                      dispatch_group_t loadingGroup = dispatch_group_create();

                      for (AVMediaCharacteristic characteristic in asset
                               .availableMediaCharacteristicsWithMediaSelectionOptions) {
                        // load each group, and add them to the array
                        dispatch_group_enter(loadingGroup);
                        [asset
                            loadMediaSelectionGroupForMediaCharacteristic:characteristic
                                                        completionHandler:^(
                                                            AVMediaSelectionGroup *_Nullable group,
                                                            NSError *_Nullable loadError) {
                                                          if (group) {
                                                            @synchronized(loadedGroups) {
                                                              [loadedGroups addObject:group];
                                                            }
                                                          }
                                                          dispatch_group_leave(loadingGroup);
                                                        }];
                      }
                      // once all groups are loaded, dispatch them
                      dispatch_group_notify(loadingGroup, dispatch_get_main_queue(), ^{
                          completionHandler([loadedGroups copy], nil);
                      });
                    }];
}

@end
