// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import Foundation
import QuartzCore

#if os(macOS)
  import Cocoa
#else
  import UIKit
#endif

// An implementation of DisplayLink using CADisplayLink.
@available(iOS 4.0, macOS 14.0, *)
class CoreAnimationDisplayLink: DisplayLink {
  private var displayLink: CADisplayLink?
  private var target: CoreAnimationDisplayLinkTarget

  /// Initializes a display link that calls the given callback when fired.
  ///
  /// The display link starts paused, so must be started, by setting 'running' to true, before the
  /// callback will fire.
  init(viewProvider: ViewProvider, callback: @escaping (() -> Void)) {
    target = CoreAnimationDisplayLinkTarget(callback: callback)
    let selector = #selector(CoreAnimationDisplayLinkTarget.onDisplayLink(sender:))
    #if os(iOS)
      displayLink = CADisplayLink(target: target, selector: selector)
    #else
      // Use the view if one is wired up, otherwise fall back to the main screen.
      // TODO(stuartmorgan): Consider an API to inform plugins about attached view changes.
      if let view = viewProvider.view {
        displayLink = view.displayLink(target: target, selector: selector)
      } else {
        displayLink = NSScreen.main?.displayLink(target: target, selector: selector)
      }
    #endif
    displayLink?.add(to: .current, forMode: .common)
    displayLink?.isPaused = true
  }

  deinit {
    displayLink?.invalidate()
  }

  var running: Bool {
    get {
      return !(displayLink?.isPaused ?? true)
    }
    set {
      displayLink?.isPaused = !newValue
    }
  }

  var duration: CFTimeInterval {
    return displayLink?.duration ?? .zero
  }
}

/// A proxy object to act as a CADisplayLink target, to avoid retain loops, since
/// CoreAnimationDisplayLink owns its CADisplayLink, but CADisplayLink retains its target.
@available(iOS 4.0, macOS 14.0, *)
class CoreAnimationDisplayLinkTarget {
  private var callback: (() -> Void)

  /// Initializes a target object that runs the given callback when onDisplayLink: is called.
  init(callback: @escaping (() -> Void)) {
    self.callback = callback
  }

  /// Method to be called when a CADisplayLink fires.
  @objc func onDisplayLink(sender: CADisplayLink) {
    callback()
  }
}
