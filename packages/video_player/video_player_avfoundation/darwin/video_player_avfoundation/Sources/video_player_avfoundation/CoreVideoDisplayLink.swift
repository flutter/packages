// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#if os(macOS)
  import Cocoa
  import CoreVideo

  /// An implementation of DisplayLink using CVDisplayLink.
  // CVDisplayLink is deprecated; this implementation is only used on macOS < 14.0
  // where CADisplayLink is not available.
  @available(macOS, deprecated: 14.0, message: "Use CoreAnimationDisplayLink instead")
  class CoreVideoDisplayLink: DisplayLink {
    // The underlying display link implementation.
    private var displayLink: CVDisplayLink?
    // A dispatch source to move display link callbacks to the main thread.
    private var displayLinkSource: DispatchSourceUserDataAdd
    // The view provider, to get screen information.
    private var viewProvider: ViewProvider

    /// Initializes a display link that calls the given callback when fired.
    ///
    /// The display link starts paused, so must be started, by setting 'running' to true, before the
    /// callback will fire.
    init(viewProvider: ViewProvider, callback: @escaping () -> Void) {
      self.viewProvider = viewProvider
      // Create and start the main-thread dispatch queue to drive frameUpdater.
      let source = DispatchSource.makeUserDataAddSource(queue: .main)
      source.setEventHandler {
        autoreleasepool {
          callback()
        }
      }
      displayLinkSource = source
      displayLinkSource.resume()
      let sourcePointer = UnsafeMutableRawPointer(Unmanaged.passUnretained(source).toOpaque())
      if CVDisplayLinkCreateWithActiveCGDisplays(&displayLink) == kCVReturnSuccess,
        let link = displayLink
      {
        CVDisplayLinkSetOutputCallback(
          link,
          { (_, _, _, _, _, displayLinkContext) -> CVReturn in
            guard let context = displayLinkContext else { return kCVReturnSuccess }
            let source = Unmanaged<DispatchSourceUserDataAdd>.fromOpaque(context)
              .takeUnretainedValue()
            // Trigger the main-thread dispatch queue, to drive the callback there.
            source.add(data: 1)
            return kCVReturnSuccess
          },
          sourcePointer)
      }
    }

    deinit {
      if let displayLink {
        CVDisplayLinkStop(displayLink)
      }
      displayLinkSource.cancel()
    }

    var running: Bool {
      get {
        guard let link = displayLink else {
          return false
        }
        return CVDisplayLinkIsRunning(link)
      }
      set {
        guard newValue != running, let link = displayLink else {
          return
        }
        if newValue {
          // TODO(stuartmorgan): Move this to init + a screen change listener; this won't correctly
          // handle windows being dragged to another screen until the next pause/play cycle. That will
          // likely require new plugin registrar APIs.
          if let screen = viewProvider.view?.window?.screen,
            let displayID = screen.deviceDescription[
              NSDeviceDescriptionKey("NSScreenNumber")] as? CGDirectDisplayID
          {
            CVDisplayLinkSetCurrentCGDisplay(link, displayID)
          }
          CVDisplayLinkStart(link)
        } else {
          CVDisplayLinkStop(link)
        }
      }
    }

    var duration: CFTimeInterval {
      guard let link = displayLink else {
        return .zero
      }
      var timestamp = CVTimeStamp()
      guard CVDisplayLinkGetCurrentTime(link, &timestamp) == kCVReturnSuccess else {
        return .zero
      }
      return CFTimeInterval(timestamp.videoRefreshPeriod) / CFTimeInterval(timestamp.videoTimeScale)
    }
  }
#endif
