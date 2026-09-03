// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Opt-in event logging for diagnosing what the texture hands the engine.
///
/// A texture player serves a placeholder buffer between loading a new asset and
/// decoding that asset's first frame. Whether the engine composites that
/// placeholder -- and for how long -- cannot be seen from Dart, which only
/// learns that the item reached AVPlayerItemStatusReadyToPlay. These events
/// close that gap: they timestamp the load, the placeholder being served, and
/// the first real frame, against the same wall clock the Dart side logs.
///
/// Off unless switched on, so it costs one already-resolved BOOL on the frame
/// path in every normal build. Two ways to switch it on:
///
///  - the app calls `setEnabled` on the `flutter.dev/videoPlayer/diag` method
///    channel, which is how tool/videodiag/ in the app repo drives it, and the
///    only way that works on a physical device without editing a scheme;
///  - the process environment sets VIDEO_DIAG=1, which catches events emitted
///    before Dart gets a chance to make that call.
extern BOOL FVPDiagEnabled(void);

/// Switches logging on or off at runtime; see the method channel above.
extern void FVPDiagSetEnabled(BOOL enabled);

/// Whether a texture player withholds readiness until its decoder has a frame.
///
/// On by default. The switch exists so a harness can measure both arms from one
/// binary: the window being closed is a frame or two wide, and comparing it
/// across two builds would compare two different timing environments as well.
extern BOOL FVPFirstFrameGatingEnabled(void);
extern void FVPFirstFrameGatingSetEnabled(BOOL enabled);

/// Milliseconds after a load during which the texture refuses to pick up a new
/// buffer, so it keeps handing the engine its placeholder. Zero, normally.
///
/// The hole this investigation is about is one display frame wide, and the
/// simulator's screen recorder captures around 17 frames a second -- it cannot
/// resolve the thing being looked for. Holding the placeholder stretches that
/// hole to something the recorder catches, which is what makes it possible to
/// see what a hole actually looks like on screen: the placeholder, whatever is
/// painted behind the texture, or the previous video's last frame.
extern double FVPDiagPlaceholderHoldMs(void);
extern void FVPDiagSetPlaceholderHoldMs(double milliseconds);

/// Logs one `[VideoDiag/ios]` line, prefixed with the wall clock in
/// milliseconds so the app's own `[VideoDiag]` lines interleave with these.
extern void FVPDiagLog(NSString *format, ...) NS_FORMAT_FUNCTION(1, 2);

/// Logs only when FVPDiagEnabled(), and evaluates its arguments only then.
#define FVP_DIAG(...)        \
  do {                       \
    if (FVPDiagEnabled()) {   \
      FVPDiagLog(__VA_ARGS__); \
    }                        \
  } while (0)

NS_ASSUME_NONNULL_END
