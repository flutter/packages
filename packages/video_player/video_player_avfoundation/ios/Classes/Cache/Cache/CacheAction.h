#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CacheType) { CacheTypeLocal = 0, CacheTypeRemote };

@interface CacheAction : NSObject

- (instancetype)initWithActionType:(CacheType)cacheType range:(NSRange)range;

@property(nonatomic) CacheType cacheType;
@property(nonatomic) NSRange range;

@end
