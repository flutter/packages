#import <AVFoundation/AVFoundation.h>

#import "../video_player_avfoundation/include/video_player_avfoundation/FVPNativeVideoView.h"

@interface FVPPlayerView : UIView
@end

@implementation FVPPlayerView
+ (Class)layerClass {
  return [AVPlayerLayer class];
}

- (void)setPlayer:(AVPlayer *)player {
  [(AVPlayerLayer *)[self layer] setPlayer:player];
}
@end

@implementation FVPNativeVideoView {
  FVPPlayerView *_view;
}

- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
              binaryMessenger:(NSObject<FlutterBinaryMessenger> *)messenger
                       player:(AVPlayer *)player {
  if (self = [super init]) {
    _view = [[FVPPlayerView alloc] init];
    [_view setPlayer:player];
  }
  return self;
}

- (FVPPlayerView *)view {
  return _view;
}

- (void)dealloc {
  [_view setPlayer:nil];
  _view = nil;
}

@end