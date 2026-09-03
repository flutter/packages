// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "./include/video_player_avfoundation/FVPDiag.h"

static BOOL gFVPDiagEnabled = NO;

BOOL FVPDiagEnabled(void) {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    NSString *value = NSProcessInfo.processInfo.environment[@"VIDEO_DIAG"];
    if ([value isEqualToString:@"1"] || [value isEqualToString:@"true"]) {
      FVPDiagSetEnabled(YES);
    }
  });
  return gFVPDiagEnabled;
}

static BOOL gFVPFirstFrameGating = YES;

BOOL FVPFirstFrameGatingEnabled(void) { return gFVPFirstFrameGating; }

void FVPFirstFrameGatingSetEnabled(BOOL enabled) {
  gFVPFirstFrameGating = enabled;
  NSLog(@"[VideoDiag/ios] t=%.3f ev=gating.%@", NSDate.date.timeIntervalSince1970 * 1000.0,
        enabled ? @"on" : @"off");
}

static double gFVPPlaceholderHoldMs = 0.0;

double FVPDiagPlaceholderHoldMs(void) { return gFVPPlaceholderHoldMs; }

void FVPDiagSetPlaceholderHoldMs(double milliseconds) {
  gFVPPlaceholderHoldMs = milliseconds;
  if (milliseconds > 0) {
    NSLog(@"[VideoDiag/ios] t=%.3f ev=placeholder.hold ms=%.0f",
          NSDate.date.timeIntervalSince1970 * 1000.0, milliseconds);
  }
}

void FVPDiagSetEnabled(BOOL enabled) {
  if (gFVPDiagEnabled == enabled) {
    return;
  }
  gFVPDiagEnabled = enabled;
  NSLog(@"[VideoDiag/ios] t=%.3f ev=diag.%@",
        NSDate.date.timeIntervalSince1970 * 1000.0, enabled ? @"enabled" : @"disabled");
}

void FVPDiagLog(NSString *format, ...) {
  va_list args;
  va_start(args, format);
  NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
  va_end(args);
  // Wall clock rather than CACurrentMediaTime: the Dart side has no access to
  // the mach timebase, and both streams have to land on one timeline.
  NSLog(@"[VideoDiag/ios] t=%.3f %@", NSDate.date.timeIntervalSince1970 * 1000.0,
        message);
}
