#import "CacheAction.h"

@implementation CacheAction

- (instancetype)initWithActionType:(CacheActionType)actionType range:(NSRange)range {
    self = [super init];
    if (self) {
        _actionType = actionType;
        _range = range;
    }
    return self;
}

- (BOOL)isEqual:(CacheAction *)object {
    if (!NSEqualRanges(object.range, self.range)) {
        return NO;
    }
    
    if (object.actionType != self.actionType) {
        return NO;
    }
    
    return YES;
}

- (NSUInteger)hash {
    return [[NSString stringWithFormat:@"%@%@", NSStringFromRange(self.range), @(self.actionType)] hash];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"actionType %@, range: %@", @(self.actionType), NSStringFromRange(self.range)];
}

@end
