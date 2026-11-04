// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation

/// Protocol for abstracting access to an AVPlayerItemVideoOutput, to enable unit testing.
protocol PixelBufferSource {
  /// Wraps the underlying videoOutput's itemTimeForHostTime: method.
  func itemTime(forHostTime hostTimeInSeconds: CFTimeInterval) -> CMTime

  /// Wraps the underlying videoOutput's hasNewPixelBufferForItemTime: method.
  func hasNewPixelBuffer(forItemTime itemTime: CMTime) -> Bool

  /// Wraps the underlying videoOutput's copyPixelBufferForItemTime:itemTimeForDisplay: method.
  func copyPixelBuffer(
    forItemTime itemTime: CMTime,
    itemTimeForDisplay outItemTimeForDisplay: UnsafeMutablePointer<CMTime>?
  ) -> CVPixelBuffer?

  /// The underlying AVFoundation object.
  ///
  /// This can't be fully abstracted away because it's passed to other AVFoundation calls. Plugin
  /// code should only use this to pass into AVFoundation; other calls should be made on the
  /// protocol.
  var videoOutput: AVPlayerItemVideoOutput { get }
}

/// Protocol for abstracting access to an AVAsset, to enable unit testing.
protocol WrappedAVAsset: AnyObject {
  /// Wraps the underlying asset's load(_:isolation:) method.
  func load<T>(_ property: AVAsyncProperty<AVAsset, T>, isolation: isolated (any Actor)?)
    async throws -> T
}

/// Protocol for abstracting access to an AVPlayerItem, to enable unit testing.
protocol WrappedAVPlayerItem: AnyObject {
  /// Wraps the underlying playerItem's asset property.
  var asset: any WrappedAVAsset { get }

  /// Wraps the underlying playerItem's videoComposition property.
  var videoComposition: AVVideoComposition? { get set }

  /// Wraps the underlying playerItem's preferredForwardBufferDuration property.
  var preferredForwardBufferDuration: TimeInterval { get set }
}

#if os(iOS)
  /// Protocol for abstracting access to an AVAudioSession, to enable unit testing.
  protocol WrappedAVAudioSession: AnyObject {
    /// Wraps the AVAudioSession property of the same name.
    var category: AVAudioSession.Category { get }
    /// Wraps the AVAudioSession property of the same name.
    var categoryOptions: AVAudioSession.CategoryOptions { get }
    /// Wraps the AVAudioSession method of the same name.
    func setCategory(
      _ category: AVAudioSession.Category,
      options: AVAudioSession.CategoryOptions) throws
  }
#endif

/// Protocol for AVFoundation object instance factory. Used for injecting framework objects in
/// tests.
protocol WrappedAVObjectFactory {
  /// Creates and returns a wrapped AVAsset instance with the specified URL and options.
  func urlAsset(with url: URL, options: [String: Any]?) -> any WrappedAVAsset

  /// Creates and returns a wrapped AVPlayerItem instance with the specified asset.
  func playerItem(with asset: any WrappedAVAsset) -> any WrappedAVPlayerItem

  /// Creates and returns an AVPlayer instance with the specified player item.
  func player(with playerItem: any WrappedAVPlayerItem) -> AVPlayer

  /// Creates and returns a wrapped AVPlayerItemVideoOutput instance with the specified output
  /// settings. The dictionary may contain both video output keys (e.g. AVVideoColorPropertiesKey)
  /// and CVPixelBuffer attribute keys (e.g. kCVPixelBufferPixelFormatTypeKey), as accepted by
  /// -[AVPlayerItemVideoOutput initWithOutputSettings:].
  func videoOutput(outputSettings: [String: Any]) -> PixelBufferSource

  #if os(iOS)
    /// Returns the AVAudioSession shared instance, wrapped in the protocol.
    func sharedAudioSession() -> WrappedAVAudioSession
  #endif
}

/// A default implementation of the WrappedAVObjectFactory protocol, using real AVFoundation objects.
class DefaultAVFactory: WrappedAVObjectFactory {
  func urlAsset(with url: URL, options: [String: Any]?) -> any WrappedAVAsset {
    return DefaultAVAsset(asset: AVURLAsset(url: url, options: options))
  }

  func playerItem(with asset: any WrappedAVAsset) -> any WrappedAVPlayerItem {
    // The default factory always vends Default* implementations, so it is safe to cast back.
    return DefaultAVPlayerItem(playerItem: AVPlayerItem(asset: (asset as! DefaultAVAsset).avAsset))
  }

  func player(with playerItem: any WrappedAVPlayerItem) -> AVPlayer {
    // The default factory always vends Default* implementations, so it is safe to cast back.
    return AVPlayer(playerItem: (playerItem as! DefaultAVPlayerItem).avPlayerItem)
  }

  func videoOutput(outputSettings: [String: Any]) -> any PixelBufferSource {
    return DefaultAVPlayerItemVideoOutput(outputSettings: outputSettings)
  }

  #if os(iOS)
    func sharedAudioSession() -> WrappedAVAudioSession {
      return DefaultAVAudioSession()
    }
  #endif
}

class DefaultAVAsset: WrappedAVAsset {
  let avAsset: AVAsset

  init(asset: AVAsset) {
    self.avAsset = asset
  }

  func load<T>(_ property: AVAsyncProperty<AVAsset, T>, isolation: isolated (any Actor)?)
    async throws -> T
  {
    return try await avAsset.load(property, isolation: isolation)
  }
}

class DefaultAVPlayerItem: WrappedAVPlayerItem {
  let avPlayerItem: AVPlayerItem

  init(playerItem: AVPlayerItem) {
    self.avPlayerItem = playerItem
  }

  var asset: WrappedAVAsset {
    return DefaultAVAsset(asset: avPlayerItem.asset)
  }

  var videoComposition: AVVideoComposition? {
    get {
      return avPlayerItem.videoComposition
    }
    set {
      avPlayerItem.videoComposition = newValue
    }
  }

  var preferredForwardBufferDuration: TimeInterval {
    get {
      return avPlayerItem.preferredForwardBufferDuration
    }
    set {
      avPlayerItem.preferredForwardBufferDuration = newValue
    }
  }
}

class DefaultAVPlayerItemVideoOutput: PixelBufferSource {
  let videoOutput: AVPlayerItemVideoOutput

  init(outputSettings: [String: Any]) {
    videoOutput = AVPlayerItemVideoOutput(outputSettings: outputSettings)
  }

  func itemTime(forHostTime hostTimeInSeconds: CFTimeInterval) -> CMTime {
    return videoOutput.itemTime(forHostTime: hostTimeInSeconds)
  }

  func hasNewPixelBuffer(forItemTime itemTime: CMTime) -> Bool {
    return videoOutput.hasNewPixelBuffer(forItemTime: itemTime)
  }

  func copyPixelBuffer(
    forItemTime itemTime: CMTime,
    itemTimeForDisplay outItemTimeForDisplay: UnsafeMutablePointer<CMTime>?
  ) -> CVPixelBuffer? {
    return videoOutput.copyPixelBuffer(
      forItemTime: itemTime, itemTimeForDisplay: outItemTimeForDisplay)
  }
}

#if os(iOS)
  class DefaultAVAudioSession: WrappedAVAudioSession {
    var category: AVAudioSession.Category {
      return AVAudioSession.sharedInstance().category
    }

    var categoryOptions: AVAudioSession.CategoryOptions {
      return AVAudioSession.sharedInstance().categoryOptions
    }

    func setCategory(
      _ category: AVAudioSession.Category, options: AVAudioSession.CategoryOptions
    ) throws {
      try AVAudioSession.sharedInstance().setCategory(category, options: options)
    }
  }
#endif
