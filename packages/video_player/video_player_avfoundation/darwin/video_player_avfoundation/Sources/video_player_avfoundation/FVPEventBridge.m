// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/video_player_avfoundation/FVPEventBridge.h"

#import <Foundation/Foundation.h>

#if TARGET_OS_OSX
#import <FlutterMacOS/FlutterMacOS.h>
#else
#import <Flutter/Flutter.h>
#endif

@interface FVPEventBridge () <FlutterStreamHandler>

/// The event channel to dispatch notifications to.
// TODO(stuartmorgan): Convert this to Pigeon event channels once the plugin is using Swift
// Pigeon generation.
@property(nonatomic) FlutterEventChannel *eventChannel;

/// The event sink associated with eventChannel.
///
/// Will be nil both before the channel listener is ready on the Dart side, and after it has been
/// closed on the Dart side.
@property(nonatomic, nullable) FlutterEventSink eventSink;

/// A queue of events received before eventSink is ready, to dispatch once the channel is fully
/// set up.
@property(nonatomic) NSMutableArray<NSObject *> *queuedEvents;

@end

@implementation FVPEventBridge

- (instancetype)initWithMessenger:(NSObject<FlutterBinaryMessenger> *)messenger
                      channelName:(NSString *)channelName {
  self = [super init];
  if (self) {
    _queuedEvents = [[NSMutableArray alloc] init];
    _eventChannel = [FlutterEventChannel eventChannelWithName:channelName
                                              binaryMessenger:messenger];
    // This retain loop is broken in videoPlayerWasDisposed.
    [_eventChannel setStreamHandler:self];
  }
  return self;
}

#pragma mark FlutterStreamHandler

- (FlutterError *_Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(nonnull FlutterEventSink)events {
  self.eventSink = events;

  // Send any events that came in before the sink was ready.
  for (id event in self.queuedEvents) {
    self.eventSink(event);
  }
  [self.queuedEvents removeAllObjects];

  return nil;
}

- (FlutterError *_Nullable)onCancelWithArguments:(id _Nullable)arguments {
  self.eventSink = nil;
  // No need to queue events coming in after this point; nil the queue so they will be discarded.
  self.queuedEvents = nil;
  return nil;
}

#pragma mark FVPVideoEventListener

- (void)videoPlayerDidInitializeWithDuration:(int64_t)duration size:(CGSize)size {
  [self sendOrQueue:@{
    @"event" : @"initialized",
    @"duration" : @(duration),
    @"width" : @(size.width),
    @"height" : @(size.height)
  }];
}

- (void)videoPlayerDidErrorWithMessage:(NSString *)errorMessage {
  [self sendOrQueue:[FlutterError errorWithCode:@"VideoError" message:errorMessage details:nil]];
}

- (void)videoPlayerDidComplete {
  [self sendOrQueue:@{@"event" : @"completed"}];
}

- (void)videoPlayerDidStartBuffering {
  [self sendOrQueue:@{@"event" : @"bufferingStart"}];
}

- (void)videoPlayerDidEndBuffering {
  [self sendOrQueue:@{@"event" : @"bufferingEnd"}];
}

- (void)videoPlayerDidUpdateBufferRegions:(NSArray<NSArray<NSNumber *> *> *)regions {
  [self sendOrQueue:@{@"event" : @"bufferingUpdate", @"values" : regions}];
}

- (void)videoPlayerDidSetPlaying:(BOOL)playing {
  [self sendOrQueue:@{@"event" : @"isPlayingStateUpdate", @"isPlaying" : @(playing)}];
}

- (void)videoPlayerWasDisposed {
  [self.eventChannel setStreamHandler:nil];
}

#pragma mark Private methods

/// Sends the given event to the event sink if it is ready to receive events, or enqueues it to send
/// later if not.
- (void)sendOrQueue:(id)event {
  if (self.eventSink) {
    self.eventSink(event);
  } else {
    [self.queuedEvents addObject:event];
  }
}

@end
