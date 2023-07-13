
#import <Foundation/Foundation.h>
#import "CacheConfiguration.h"

@class CacheAction;

@interface ContentCacheWorker : NSObject

- (instancetype)initWithURL:(NSURL *)url;

@property(nonatomic, strong, readonly) CacheConfiguration *cacheConfiguration;
@property(nonatomic, strong, readonly) NSError *setupError;
- (void)cacheData:(NSData *)data forRange:(NSRange)range error:(NSError **)error;
- (NSArray<CacheAction *> *)cachedDataActionsForRange:(NSRange)range;
- (NSData *)cachedDataForRange:(NSRange)range error:(NSError **)error;

- (void)setContentInfo:(ContentInfo *)contentInfo error:(NSError **)error;

- (void)save;

- (void)startWritting;
- (void)finishWritting;

@end
