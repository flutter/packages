// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "../video_player_avfoundation/include/video_player_avfoundation/FVPDisplayLink.h"

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

/// A proxy object to act as a CADisplayLink target, to avoid retain loops, since FVPCADisplayLink
/// owns its CADisplayLink, but CADisplayLink retains its target.
API_AVAILABLE(ios(4.0), macos(14.0))
@interface FVPDisplayLinkTarget : NSObject
@property(nonatomic) void (^callback)(void);

/// Initializes a target object that runs the given callback when onDisplayLink: is called.
- (instancetype)initWithCallback:(void (^)(void))callback;

/// Method to be called when a CADisplayLink fires.
- (void)onDisplayLink:(CADisplayLink *)link;
@end

@implementation FVPDisplayLinkTarget
- (instancetype)initWithCallback:(void (^)(void))callback {
  self = [super init];
  if (self) {
    _callback = callback;
  }
  return self;
}

- (void)onDisplayLink:(CADisplayLink *)link {
  self.callback();
}
@end

#pragma mark -

@interface FVPCADisplayLink ()
// The underlying display link implementation.
@property(nonatomic) CADisplayLink *displayLink;
@property(nonatomic) FVPDisplayLinkTarget *target;
@end

@implementation FVPCADisplayLink

- (instancetype)initWithRegistrar:(id<FlutterPluginRegistrar>)registrar
                         callback:(void (^)(void))callback {
  self = [super init];
  if (self) {
    _target = [[FVPDisplayLinkTarget alloc] initWithCallback:callback];
#if TARGET_OS_IOS
    _displayLink = [CADisplayLink displayLinkWithTarget:_target selector:@selector(onDisplayLink:)];
#else
    // Use the view if one is wired up, otherwise fall back to the main screen.
    // TODO(stuartmorgan): Consider an API to inform plugins about attached view changes.
    NSView *view = registrar.view;
    _displayLink = view ? [view displayLinkWithTarget:_target selector:@selector(onDisplayLink:)]
                        : [NSScreen.mainScreen displayLinkWithTarget:_target
                                                            selector:@selector(onDisplayLink:)];
#endif
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    _displayLink.paused = YES;
  }
  return self;
}

- (void)dealloc {
  [_displayLink invalidate];
}

- (BOOL)running {
  return !self.displayLink.paused;
}

- (void)setRunning:(BOOL)running {
  self.displayLink.paused = !running;
}

- (CFTimeInterval)duration {
  return self.displayLink.duration;
}

@end
