#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CacheActionType) { CacheActionTypeLocal = 0, CacheActionTypeRemote };

@interface CacheAction : NSObject

- (instancetype)initWithActionType:(CacheActionType)actionType range:(NSRange)range;

@property(nonatomic) CacheActionType actionType;
@property(nonatomic) NSRange range;

@end
