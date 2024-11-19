#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

#if TARGET_OS_OSX
@interface FVPNativeVideoView : NSView
#else
@interface FVPNativeVideoView : NSObject <FlutterPlatformView>
#endif
- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
              binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger
                       player:(AVPlayer *)player;

#if TARGET_OS_OSX
- (NSView *)view;
#else
- (UIView *)view;
#endif
@end
