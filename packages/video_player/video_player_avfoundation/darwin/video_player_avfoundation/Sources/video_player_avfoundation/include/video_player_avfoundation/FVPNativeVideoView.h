#import <Flutter/Flutter.h>

@interface FVPNativeVideoView : NSObject <FlutterPlatformView>
- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
              binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger
                       player:(AVPlayer *)player;

- (UIView *)view;
@end
