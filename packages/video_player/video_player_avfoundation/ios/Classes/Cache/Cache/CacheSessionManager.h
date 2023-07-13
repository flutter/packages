
#import <Foundation/Foundation.h>

@interface CacheSessionManager : NSObject

@property(nonatomic, strong, readonly) NSOperationQueue *downloadQueue;

+ (instancetype)shared;

@end
