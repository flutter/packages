// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// Adds a `maybe` method to Enum.values to retrieve them by their name
/// without throwing.
extension MaybeEnum<T extends Enum> on List<T> {
  /// Attempts to retrieve an enum of type T by its [name].
  T? maybe(String? name) {
    for (final T value in this) {
      if (value.name == name) {
        return value;
      }
    }
    return null;
  }
}

/// Available types of Ad Breaks.
enum BreakType {
  /// Before the app loads (before UI has rendered).
  preroll,

  /// Before the app flow starts (after UI has rendered).
  start,

  /// When the user pauses the app.
  pause,

  /// When the user navigates to the next screen.
  next,

  /// When the user explores options.
  browse,

  /// Rewarded ad.
  reward,
}

/// The set of [BreakType]s that can be used in [AdBreakPlacement.interstitial].
const Set<BreakType> interstitialBreakType = <BreakType>{
  BreakType.start,
  BreakType.pause,
  BreakType.next,
  BreakType.browse,
};

/// Available formats of Ad Breaks.
enum BreakFormat {
  /// Used in the middle of content
  interstitial,

  /// User gets rewarded for watching the entire ad
  reward,
}

/// Response from AdSense, provided as param of the adBreakDone callback
enum BreakStatus {
  /// The Ad Placement API had not initialized.
  notReady,

  /// A placement timed out because the Ad Placement API took too long to respond.
  timeout,

  /// There was a JavaScript error in a callback.
  error,

  /// An ad had not been preloaded yet so this placement was skipped.
  noAdPreloaded,

  /// An ad wasn't shown because the frequency cap was applied to this placement.
  frequencyCapped,

  /// The user didn't click on a reward prompt before they reached the next placement.
  ///
  /// That is showAdFn() wasn't called before the next adBreak().
  ignored,

  /// The ad was not shown for another reason.
  ///
  /// (e.g., The ad was still being fetched, or a previously cached ad was
  /// disposed because the screen was resized/rotated.)
  other,

  /// The user dismissed a rewarded ad before viewing it to completion.
  dismissed,

  /// The ad was viewed by the user.
  viewed,

  /// The placement was invalid and was ignored.
  ///
  /// For instance there should only be one preroll placement per page load,
  /// subsequent prerolls are failed with this status.
  invalid,
}

/// Whether ads should always be preloaded before the first call to `adBreak`.
enum PreloadAdBreaks {
  /// Always preload.
  on,

  /// Leaves the decision up to the Ad Placement API.
  auto,
}

/// Whether the app is plays sounds during normal operations.
enum SoundEnabled {
  /// Sound is played.
  on,

  /// Sound is never played.
  off,
}
