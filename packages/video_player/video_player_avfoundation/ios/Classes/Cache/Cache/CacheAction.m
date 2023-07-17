#import "CacheAction.h"

@implementation CacheAction

- (instancetype)initWithActionType:(CacheType)actionType range:(NSRange)range {
  self = [super init];
  if (self) {
    _cacheType = actionType;
    _range = range;
  }
  return self;
}

- (BOOL)isEqual:(CacheAction *)object {
    return NSEqualRanges(object.range, self.range) && object.cacheType == self.cacheType;
}

@end
