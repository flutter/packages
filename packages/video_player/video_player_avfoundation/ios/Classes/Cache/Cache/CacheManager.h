
#import <Foundation/Foundation.h>
#import "CacheConfiguration.h"

extern NSString *CacheConfigurationKey;
extern NSString *CacheFinishedErrorKey;

@interface CacheManager : NSObject

+ (NSString *)cachedFilePathForURL:(NSURL *)url;
+ (CacheConfiguration *)cacheConfigurationForURL:(NSURL *)url;

+ (void)cleanAllCacheWithError:(NSError **)error;

@end
