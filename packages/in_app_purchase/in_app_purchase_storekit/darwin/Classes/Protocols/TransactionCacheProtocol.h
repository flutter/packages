#import "FIATransactionCache.h"
#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@protocol TransactionCache <NSObject>
- (void)addObjects:(NSArray *)objects forKey:(TransactionCacheKey)key;
- (NSArray *)getObjectsForKey:(TransactionCacheKey)key;
- (void)clear;
@end

@interface DefaultTransactionCache : NSObject <TransactionCache>
@property(strong, nonatomic) FIATransactionCache *cache;
- (instancetype)initWithCache:(FIATransactionCache *)cache;
@end

NS_ASSUME_NONNULL_END
