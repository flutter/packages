// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "../video_player_avfoundation/include/video_player_avfoundation/FVPDisplayLink.h"

#import <CoreVideo/CoreVideo.h>
#import <Foundation/Foundation.h>

@interface FVPDisplayLink ()
// The underlying display link implementation.
@property(nonatomic, assign) CVDisplayLinkRef displayLink;
// A dispatch source to move display link callbacks to the main thread.
@property(nonatomic, strong) dispatch_source_t displayLinkSource;
// The plugin registrar, to get screen information.
@property(nonatomic, weak) NSObject<FlutterPluginRegistrar> *registrar;
@end

static CVReturn DisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp *now,
                                    const CVTimeStamp *outputTime, CVOptionFlags flagsIn,
                                    CVOptionFlags *flagsOut, void *displayLinkSource) {
  // Trigger the main-thread dispatch queue, to drive the callback there.
  __weak dispatch_source_t source = (__bridge dispatch_source_t)displayLinkSource;
  dispatch_source_merge_data(source, 1);
  return kCVReturnSuccess;
}

@implementation FVPDisplayLink

- (instancetype)initWithRegistrar:(id<FlutterPluginRegistrar>)registrar
                         callback:(void (^)(void))callback {
  self = [super init];
  if (self) {
    _registrar = registrar;
    // Create and start the main-thread dispatch queue to drive frameUpdater.
    _displayLinkSource =
        dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_event_handler(_displayLinkSource, ^() {
      @autoreleasepool {
        callback();
      }
    });
    dispatch_resume(_displayLinkSource);
    if (CVDisplayLinkCreateWithActiveCGDisplays(&_displayLink) == kCVReturnSuccess) {
      CVDisplayLinkSetOutputCallback(_displayLink, &DisplayLinkCallback,
                                     (__bridge void *)(_displayLinkSource));
    }
  }
  return self;
}

- (void)dealloc {
  CVDisplayLinkStop(_displayLink);
  CVDisplayLinkRelease(_displayLink);
  _displayLink = NULL;

  dispatch_source_cancel(_displayLinkSource);
}

- (BOOL)running {
  return CVDisplayLinkIsRunning(self.displayLink);
}

- (void)setRunning:(BOOL)running {
  if (self.running == running) {
    return;
  }
  if (running) {
    // TODO(stuartmorgan): Move this to init + a screen change listener; this won't correctly
    // handle windows being dragged to another screen until the next pause/play cycle. That will
    // likely require new plugin registrar APIs.
    NSScreen *screen = self.registrar.view.window.screen;
    if (screen) {
      CGDirectDisplayID viewDisplayID =
          (CGDirectDisplayID)[screen.deviceDescription[@"NSScreenNumber"] unsignedIntegerValue];
      CVDisplayLinkSetCurrentCGDisplay(self.displayLink, viewDisplayID);
    }
    CVDisplayLinkStart(self.displayLink);
  } else {
    CVDisplayLinkStop(self.displayLink);
  }
}

@end
