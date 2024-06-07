#import "TransactionCacheProtocol.h"

@implementation DefaultTransactionCache
- (void)addObjects:(nonnull NSArray *)objects forKey:(TransactionCacheKey)key {
  [self.cache addObjects:objects forKey:key];
}

- (void)clear {
  [self.cache clear];
}

- (nonnull NSArray *)getObjectsForKey:(TransactionCacheKey)key {
  return [self.cache getObjectsForKey:key];
}

- (nonnull instancetype)initWithCache:(nonnull FIATransactionCache *)cache {
  self = [super init];
  if (self) {
    _cache = cache;
  }
  return self;
}
@end
