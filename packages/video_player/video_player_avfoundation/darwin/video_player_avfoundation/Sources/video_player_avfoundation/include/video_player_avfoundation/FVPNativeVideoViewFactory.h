#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

#import "FVPVideoPlayer.h"

@interface FVPNativeVideoViewFactory : NSObject <FlutterPlatformViewFactory>
- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messenger
               playersByTextureId:
                   (NSMutableDictionary<NSNumber *, FVPVideoPlayer *> *)playersByTextureId;
@end
