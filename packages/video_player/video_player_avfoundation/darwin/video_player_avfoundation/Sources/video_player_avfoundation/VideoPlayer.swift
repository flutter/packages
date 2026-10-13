// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AVFoundation
import CoreMedia

#if os(iOS)
  import Flutter
#elseif os(macOS)
  import FlutterMacOS
#else
  #error("Unsupported platform.")
#endif

#if canImport(video_player_avfoundation_objc)
  import video_player_avfoundation_objc
#endif

// Forwarding bridge to handle Pigeon callbacks without preventing VideoPlayer from
// being annotated as @MainActor. Synchronous methods use assumeIsolated since they
// are guaranteed to be called on the main thread, and async methods rely on the `await`
// moving to the correct thread if the call to this bridge jumped off of main.
// TODO(stuartmorgan): Remove this once https://github.com/flutter/flutter/issues/194655
// is fixed, by making VideoPlayerInstanceApi a @MainActor protocol and returning to
// having VideoPlayer conform to it.
class VideoPlayerInstanceBridge: VideoPlayerInstanceApi {
  private weak var player: VideoPlayer?

  init(player: VideoPlayer) {
    self.player = player
  }

  func setLooping(_ looping: Bool) throws {
    MainActor.assumeIsolated {
      player?.setLooping(looping)
    }
  }

  func setVolume(_ volume: Double) throws {
    MainActor.assumeIsolated {
      player?.setVolume(volume)
    }
  }

  func setPlaybackSpeed(_ speed: Double) throws {
    MainActor.assumeIsolated {
      player?.setPlaybackSpeed(speed)
    }
  }

  func play() throws {
    MainActor.assumeIsolated {
      player?.play()
    }
  }

  func getPosition() throws -> Int64 {
    MainActor.assumeIsolated {
      return player?.getPosition() ?? 0
    }
  }

  func seek(to position: Int64) async throws {
    try await player?.seek(to: position)
  }

  func pause() throws {
    MainActor.assumeIsolated {
      player?.pause()
    }
  }

  func dispose() throws {
    MainActor.assumeIsolated {
      player?.dispose()
    }
  }

  func getAudioTracks() async throws -> [MediaSelectionAudioTrackData] {
    return try await player?.getAudioTracks() ?? []
  }

  func selectAudioTrack(atIndex trackIndex: Int64) async throws {
    try await player?.selectAudioTrack(atIndex: trackIndex)
  }

  func getVideoTracks() async throws -> NativeVideoTrackData {
    return try await player?.getVideoTracks() ?? NativeVideoTrackData()
  }

  func selectVideoTrack(withBitrate bitrate: Int64) throws {
    MainActor.assumeIsolated {
      player?.selectVideoTrack(withBitrate: bitrate)
    }
  }

  func setPreventsDisplaySleepDuringVideoPlayback(_ preventsDisplaySleepDuringVideoPlayback: Bool)
    throws
  {
    MainActor.assumeIsolated {
      player?.setPreventsDisplaySleepDuringVideoPlayback(preventsDisplaySleepDuringVideoPlayback)
    }
  }

}

/// VideoPlayer manages video playback using AVPlayer.
/// It provides methods for controlling playback, adjusting volume, and handling seeking.
/// This class contains all functionalities needed to manage video playback in platform views and is
/// typically used alongside NativeVideoViewFactory. If you need to display a video using a
/// texture, use TextureBasedVideoPlayer instead.
// TODO(stuartmorgan): Consider moving TextureBasedVideoPlayer's FlutterTexture implementation
// to a small bridge object to avoid the need to inherit from NSObject here.
// TODO(stuartmorgan): Add VideoPlayerInstanceApi conformance here once it has actor
// annotations. See TODO on VideoPlayerInstanceBridge above.
@MainActor
class VideoPlayer: NSObject {
  /// The AVPlayer instance used for video playback.
  let player: AVPlayer
  /// The VideoPlayerInstanceApi implementation that forwards calls to this object.
  private(set) var hostApiBridge: VideoPlayerInstanceBridge!
  /// Indicates whether the video player has been disposed.
  private(set) var disposed = false
  /// Indicates whether the video player is set to loop.
  private(set) var isLooping = false
  /// Indicates whether the video player is currently playing.
  private(set) var isPlaying = false
  /// The event listener to report video events to.
  private(set) var eventListener: VideoEventListener?
  /// A block that will be called when dispose is called.
  var onDisposed: (() -> Void)?

  /// The pixel buffer source associated with this video player.
  let pixelBufferSource: PixelBufferSource
  /// The view provider, to obtain view information from.
  let viewProvider: FVPViewProvider
  /// The preferred transform for the video. It can be used to handle the rotation of the video.
  private var preferredTransform: CGAffineTransform = .identity
  /// The target playback speed requested by the plugin client.
  private var targetPlaybackSpeed: Double?
  /// Indicates whether an "initialized" message has been sent to the current Flutter event listener.
  ///
  /// The video player sends an "initialized" message to the event listener when its underlying
  /// AVPlayerItem is ready to play and the event listener is set to a non-nil value, whichever occurs
  /// last.
  ///
  /// This flag is set to true when the "initialized" message is first sent, and is never set to
  /// false again.
  private var isInitialized = false

  private var keyValueObservations: [NSKeyValueObservation] = []
  private var playToEndObserver: NSObjectProtocol?

  /// Initializes a new instance of VideoPlayer with the given AVPlayerItem, AV factory, and view
  /// provider.
  init(
    playerItem: WrappedAVPlayerItem,
    avFactory: WrappedAVObjectFactory,
    viewProvider: FVPViewProvider
  ) {
    self.viewProvider = viewProvider

    let asset = playerItem.asset

    player = avFactory.player(with: playerItem)
    player.actionAtItemEnd = .none

    #if os(iOS)
      // Allow the video to follow an AirPlay route to an external device.
      //
      // allowsExternalPlayback already defaults to YES, but
      // usesExternalPlaybackWhileExternalScreenIsActive defaults to NO, so the
      // player deliberately keeps the picture on the device whenever an external
      // screen is active. The result is that selecting an AirPlay route changes the
      // audio route while the video stays on the phone and the TV only receives a
      // mirrored copy of the screen.
      //
      // Verified on an Apple TV: with both set, the receiver plays the stream
      // itself and the local surface is released.
      player.allowsExternalPlayback = true
      player.usesExternalPlaybackWhileExternalScreenIsActive = true
    #endif

    // Configure output. AVVideoColorPropertiesKey must be declared on the output settings (not on
    // pixel buffer attributes, where AVFoundation silently ignores it) so that HDR sources are
    // tone-mapped to BT.709 SDR for the Flutter texture.
    // See https://github.com/flutter/flutter/issues/91241
    let outputSettings: [String: Any] = [
      AVVideoColorPropertiesKey: [
        AVVideoColorPrimariesKey: AVVideoColorPrimaries_ITU_R_709_2,
        AVVideoTransferFunctionKey: AVVideoTransferFunction_ITU_R_709_2,
        AVVideoYCbCrMatrixKey: AVVideoYCbCrMatrix_ITU_R_709_2,
      ],
      kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA),
      kCVPixelBufferIOSurfacePropertiesKey as String: [:],
    ]
    pixelBufferSource = avFactory.videoOutput(outputSettings: outputSettings)

    super.init()

    hostApiBridge = VideoPlayerInstanceBridge(player: self)

    Task { @MainActor [weak self] in
      do {
        let tracks = try await asset.load(.tracks, isolation: #isolation)
        let videoTracks = tracks.filter { $0.mediaType == .video }
        if !videoTracks.isEmpty {
          let videoTrack = videoTracks[0]
          let transform = try await videoTrack.load(.preferredTransform)
          guard let self = self else { return }
          if self.disposed { return }
          // Rotate the video by using a videoComposition and the preferredTransform
          self.preferredTransform = standardizedTrackTransform(
            transform: transform, size: try await videoTrack.load(.naturalSize))
          // Do not use video composition when it is not needed.
          if self.preferredTransform.isIdentity || self.disposed { return }
          // Note:
          // https://developer.apple.com/documentation/avfoundation/avplayeritem/1388818-videocomposition
          // Video composition can only be used with file-based media and is not supported for
          // use with media served using HTTP Live Streaming.
          let composition = try await self.createVideoComposition(
            transform: self.preferredTransform, asset: asset, videoTrack: videoTrack)
          if self.disposed { return }
          playerItem.videoComposition = composition
        }
      } catch {
        NSLog("Error loading tracks: %@", error.localizedDescription)
      }
    }
  }

  deinit {
    if let playToEndObserver = playToEndObserver {
      NotificationCenter.default.removeObserver(playToEndObserver)
    }
  }

  func setEventListener(_ eventListener: FVPVideoEventListener) async {
    self.eventListener = eventListener
    // The first time an event listener is set, set up video event listeners to relay status changes
    // changes to the event listener.
    if keyValueObservations.isEmpty && !disposed,
      let item = player.currentItem
    {
      // If the item is already ready to play, ensure that the intialized event is sent first.
      await reportStatus(playerItem: item)
      if disposed { return }
      // Set up all necessary observers to report video events.
      // In theory these callbacks should all be on the main thread, so could use
      // MainActor.assumeIsolated instead, but for now use Tasks in case they
      // are on an unexpected thread.
      keyValueObservations.append(
        item.observe(
          \.loadedTimeRanges,
          options: [.new]
        ) { [weak self] object, _ in
          Task { @MainActor in
            guard let self = self else { return }
            let values = object.loadedTimeRanges.map { rangeValue in
              let range = rangeValue.timeRangeValue
              return [
                NSNumber(value: self.convertCMTimeToMillis(range.start)),
                NSNumber(value: self.convertCMTimeToMillis(range.duration)),
              ]
            }
            self.eventListener?.videoPlayerDidUpdateBufferRegions(values)
          }
        }
      )
      keyValueObservations.append(
        item.observe(
          \.isPlaybackLikelyToKeepUp,
          options: [.new]
        ) { [weak self] object, _ in
          Task { @MainActor in
            guard let self = self else { return }
            self.updatePlayingState()
            if object.isPlaybackLikelyToKeepUp {
              self.eventListener?.videoPlayerDidEndBuffering()
            } else {
              self.eventListener?.videoPlayerDidStartBuffering()
            }
          }
        }
      )
      keyValueObservations.append(
        item.observe(
          \.status,
          options: [.new]
        ) { [weak self] object, _ in
          Task { @MainActor in
            await self?.reportStatus(playerItem: object as AVPlayerItem)
          }
        }
      )
      keyValueObservations.append(
        player.observe(
          \.rate,
          options: [.new]
        ) { [weak self] object, _ in
          Task { @MainActor in
            self?.eventListener?.videoPlayerDidSetPlaying(object.rate > 0)
          }
        }
      )

      playToEndObserver = NotificationCenter.default.addObserver(
        forName: .AVPlayerItemDidPlayToEndTime, object: item, queue: .main
      ) { [weak self] notification in
        MainActor.assumeIsolated {
          guard let item = notification.object as? AVPlayerItem else { return }
          self?.itemDidPlayToEndTime(item)
        }
      }
    }
  }

  func removeEventListener() {
    eventListener = nil
  }

  // MARK: VideoPlayerInstanceApi

  func setLooping(_ looping: Bool) {
    isLooping = looping
  }

  func setVolume(_ volume: Double) {
    player.volume = Float(min(max(volume, 0.0), 1.0))
  }

  func setPlaybackSpeed(_ speed: Double) {
    targetPlaybackSpeed = speed
    updatePlayingState()
  }

  func play() {
    isPlaying = true
    updatePlayingState()
  }

  func getPosition() -> Int64 {
    return convertCMTimeToMillis(player.currentTime())
  }

  func seek(to position: Int64) async throws {
    let targetCMTime = CMTime(value: position, timescale: 1000)
    var duration: Int64 = 0
    if let asset = player.currentItem?.asset {
      duration = try await asset.load(.duration).value
    }
    if disposed { return }
    // Without adding tolerance when seeking to duration,
    // seek(to:) will never complete, and this call will hang.
    // see issue https://github.com/flutter/flutter/issues/124475.
    let tolerance = position == duration ? CMTime(value: 1, timescale: 1000) : .zero
    await player.seek(to: targetCMTime, toleranceBefore: tolerance, toleranceAfter: tolerance)
  }

  func pause() {
    isPlaying = false
    updatePlayingState()
  }

  func dispose() {
    // In some hot restart scenarios, dispose can be called twice, so no-op after the first time.
    if disposed { return }
    disposed = true

    // Remove all observers.
    if let playToEndObserver = playToEndObserver {
      NotificationCenter.default.removeObserver(playToEndObserver)
      self.playToEndObserver = nil
    }
    keyValueObservations.removeAll()

    player.replaceCurrentItem(with: nil)

    onDisposed?()
    eventListener?.videoPlayerWasDisposed()
  }

  func getAudioTracks() async throws -> [MediaSelectionAudioTrackData] {
    guard let currentItem = player.currentItem else { return [] }

    let asset = currentItem.asset

    // Get tracks from media selection (for HLS streams)
    let audioGroup = try await asset.loadMediaSelectionGroup(for: .audible)
    guard let audioGroup = audioGroup else { return [] }
    if disposed { return [] }

    let mediaSelection = currentItem.currentMediaSelection
    let currentSelection = mediaSelection.selectedMediaOption(in: audioGroup)
    var trackData: [MediaSelectionAudioTrackData] = []
    for (i, option) in audioGroup.options.enumerated() {
      let titleItems = AVMetadataItem.metadataItems(
        from: option.commonMetadata, withKey: AVMetadataKey.commonKeyTitle, keySpace: .common)
      let languageCode =
        if #available(iOS 16.0, macOS 13.0, *) {
          option.locale?.language.languageCode?.identifier
        } else {
          option.locale?.languageCode
        }
      // Ignore failure to load a title, since titles are optional anyway.
      let title = try? await titleItems.first?.load(.stringValue)
      if disposed { return [] }
      trackData.append(
        MediaSelectionAudioTrackData(
          index: Int64(i),
          displayName: option.displayName,
          languageCode: languageCode,
          isSelected: currentSelection == option,
          commonMetadataTitle: title))
    }
    return trackData
  }

  func selectAudioTrack(atIndex trackIndex: Int64) async throws {
    guard let currentItem = player.currentItem else { return }
    let asset = currentItem.asset

    if let audioGroup = try await asset.loadMediaSelectionGroup(for: .audible) {
      if !disposed && trackIndex >= 0 && trackIndex < audioGroup.options.count {
        let option = audioGroup.options[Int(trackIndex)]
        currentItem.select(option, in: audioGroup)
      }
    }
  }

  func getVideoTracks() async throws -> NativeVideoTrackData {
    guard let currentItem = player.currentItem else {
      throw PigeonError(code: "State Error", message: "No current player item", details: nil)
    }

    guard let urlAsset = currentItem.asset as? AVURLAsset else {
      throw PigeonError(code: "State Error", message: "No current player asset", details: nil)
    }

    let variants = try await urlAsset.load(.variants)
    if disposed { return NativeVideoTrackData(assetTracks: nil, mediaSelectionTracks: nil) }
    var mediaSelectionTracks: [MediaSelectionVideoTrackData] = []
    let currentBitrate = max(currentItem.preferredPeakBitRate, 0)

    var variantIndex = 0
    for variant in variants {
      let peakBitRate = variant.peakBitRate ?? 0.0
      var videoSize = CGSize.zero
      var frameRate = 0.0
      var codec: String?

      // Get video attributes if available
      if let videoAttrs = variant.videoAttributes {
        videoSize = videoAttrs.presentationSize
        frameRate = videoAttrs.nominalFrameRate ?? 0.0
        // Get codec from media sub types
        let codecTypes = videoAttrs.codecTypes
        if !codecTypes.isEmpty {
          codec = codecStringFromFourCharCode(codecTypes[0])
        }
      }

      // Determine if this variant is currently selected by comparing
      // bitrates. Since AVPlayer doesn't expose the exact selected variant,
      // we use a 10% tolerance to account for minor bitrate variations in
      // adaptive streaming.
      let isSelected =
        currentBitrate > 0 && abs(peakBitRate - currentBitrate) < peakBitRate * 0.1

      // Generate a human-readable resolution label (e.g., "1080p")
      let resolutionLabel: String? =
        videoSize.height > 0 ? String(format: "%.0fp", videoSize.height) : nil

      let trackData = createVideoTrackData(
        index: variantIndex,
        label: resolutionLabel,
        peakBitRate: peakBitRate,
        videoSize: videoSize,
        frameRate: frameRate,
        codec: codec,
        isSelected: isSelected)
      mediaSelectionTracks.append(trackData)
      variantIndex += 1
    }

    return NativeVideoTrackData(
      assetTracks: nil,
      mediaSelectionTracks: mediaSelectionTracks)
  }

  func selectVideoTrack(withBitrate bitrate: Int64) {
    guard let currentItem = player.currentItem else { return }

    // Set preferredPeakBitRate to select the quality
    // 0 means auto quality (adaptive streaming)
    currentItem.preferredPeakBitRate = Double(bitrate)
  }

  func setPreventsDisplaySleepDuringVideoPlayback(_ preventsDisplaySleepDuringVideoPlayback: Bool) {
    player.preventsDisplaySleepDuringVideoPlayback = preventsDisplaySleepDuringVideoPlayback
  }

  // MARK: Accessible for subclass

  /// Updates the playing state of the video player.
  func updatePlayingState() {
    if !isInitialized { return }
    if isPlaying {
      // Calling play is the same as setting the rate to 1.0 (or to defaultRate depending on iOS
      // version) so last set playback speed must be set here if any instead.
      // https://github.com/flutter/flutter/issues/71264
      // https://github.com/flutter/flutter/issues/73643
      if targetPlaybackSpeed != nil {
        updateRate()
      } else {
        player.play()
      }
    } else {
      player.pause()
    }
  }

  // MARK: Private

  private func itemDidPlayToEndTime(_ item: AVPlayerItem) {
    if isLooping {
      item.seek(to: .zero) { _ in }
    } else {
      eventListener?.videoPlayerDidComplete()
    }
  }

  private func convertCMTimeToMillis(_ time: CMTime) -> Int64 {
    // For indefinite times return a value that matches TIME_UNSET from ExoPlayer2 on Android.
    // Fixes https://github.com/flutter/flutter/issues/48670
    if time.isIndefinite { return -9_223_372_036_854_775_807 }
    if time.timescale == 0 { return 0 }
    return CMTimeConvertScale(time, timescale: 1000, method: .roundTowardZero).value
  }

  private func radiansToDegrees(_ radians: CGFloat) -> Float {
    // Input range [-pi, pi] or [-180, 180]
    var degrees = Float(radians) * 180.0 / .pi
    // Convert -90 to 270 and -180 to 180
    if degrees < 0 { degrees += 360 }
    // Output degrees in between [0, 360]
    return degrees
  }

  private func createVideoComposition(
    transform: CGAffineTransform,
    asset: WrappedAVAsset,
    videoTrack: AVAssetTrack
  ) async throws -> AVMutableVideoComposition {
    let videoComposition = AVMutableVideoComposition()

    let instruction = AVMutableVideoCompositionInstruction()
    let duration = try await asset.load(.duration, isolation: #isolation)
    instruction.timeRange = CMTimeRange(start: .zero, duration: duration)
    let layerInstruction = AVMutableVideoCompositionLayerInstruction(
      assetTrack: videoTrack)
    layerInstruction.setTransform(transform, at: .zero)

    instruction.layerInstructions = [layerInstruction]
    videoComposition.instructions = [instruction]

    // If in portrait mode, switch the width and height of the video
    let naturalSize = try await videoTrack.load(.naturalSize, isolation: #isolation)
    var width = naturalSize.width
    var height = naturalSize.height
    let rotationDegrees =
      Int(round(radiansToDegrees(atan2(transform.b, transform.a))))
    if rotationDegrees == 90 || rotationDegrees == 270 {
      width = naturalSize.height
      height = naturalSize.width
    }
    videoComposition.renderSize = CGSize(width: width, height: height)

    videoComposition.sourceTrackIDForFrameTiming = videoTrack.trackID
    let minFrameDuration = try await videoTrack.load(.minFrameDuration)
    if frameDurationIsValid(minFrameDuration) {
      videoComposition.frameDuration = minFrameDuration
    } else {
      NSLog(
        "Warning: videoTrack.minFrameDuration for input video is invalid, please report this to "
          + "https://github.com/flutter/flutter/issues with input video attached.")
      videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
    }

    return videoComposition
  }

  private func reportStatus(playerItem item: AVPlayerItem) async {
    assert(
      eventListener != nil,
      "\(#function) was called when the event listener was not set.")
    switch item.status {
    case .failed:
      sendFailedToLoadVideoEvent()
    case .readyToPlay:
      if !isInitialized {
        item.add(pixelBufferSource.videoOutput)
        await reportInitialized()
        if disposed { return }
        updatePlayingState()
      }
    case .unknown:
      break
    @unknown default:
      break
    }
  }

  /// Synchronizes the player's playback rate with targetPlaybackSpeed, constrained by the playback
  /// rate capabilities of the player's current item.
  private func updateRate() {
    // See https://developer.apple.com/library/archive/qa/qa1772/_index.html for an explanation of
    // these checks.
    // If status is not AVPlayerItemStatusReadyToPlay then both canPlayFastForward
    // and canPlaySlowForward are always false and it is unknown whether video can
    // be played at these speeds, updatePlayingState will be called again when
    // status changes to AVPlayerItemStatusReadyToPlay.
    var speed = targetPlaybackSpeed ?? 1.0
    let readyToPlay = player.currentItem?.status == .readyToPlay
    if speed > 2.0 && !(player.currentItem?.canPlayFastForward ?? false) {
      if !readyToPlay { return }
      speed = 2.0
    }
    if speed < 1.0 && !(player.currentItem?.canPlaySlowForward ?? false) {
      if !readyToPlay { return }
      speed = 1.0
    }
    player.rate = Float(speed)
  }

  private func sendFailedToLoadVideoEvent() {
    // Prefer more detailed error information from tracks loading.
    var error = player.currentItem?.error
    if case .failed(let trackError)? = player.currentItem?.asset.status(of: .tracks) {
      error = trackError
    }
    let details = NSMutableOrderedSet(object: "Failed to load video")
    let addToDetails: (String?) -> Void = { detail in
      if let detail = detail {
        details.add(detail)
      }
    }
    let underlyingError = (error as? NSError)?.userInfo[NSUnderlyingErrorKey] as? NSError
    addToDetails(error?.localizedDescription)
    addToDetails((error as? NSError)?.localizedFailureReason)
    addToDetails(underlyingError?.localizedDescription)
    addToDetails(underlyingError?.localizedFailureReason)
    eventListener?.videoPlayerDidError(
      withMessage: (details.array as! [String]).joined(separator: ": "))
  }

  private func reportInitialized() async {
    let currentItem = player.currentItem
    assert(
      currentItem?.status == .readyToPlay,
      "\(#function) was called when the item wasn't ready to play.")
    assert(!isInitialized, "\(#function) should only be called once.")
    isInitialized = true
    let duration = await duration()
    eventListener?.videoPlayerDidInitialize(
      withDuration: duration, size: currentItem?.presentationSize ?? .zero)
  }

  private func duration() async -> Int64 {
    // Note: https://openradar.appspot.com/radar?id=4968600712511488
    // `AVPlayerItem.duration` can be `kCMTimeIndefinite`, so
    // use its `AVAsset.duration` instead.
    guard let asset = player.currentItem?.asset else { return 0 }
    return convertCMTimeToMillis((try? await asset.load(.duration)) ?? .zero)
  }

}

/// Converts a FourCharCode codec type to a human-readable string for display in the UI.
/// These codec names help users understand the video encoding format of each quality variant.
private func codecStringFromFourCharCode(_ code: FourCharCode) -> String? {
  switch code {
  case kCMVideoCodecType_H264:
    return "avc1"
  case kCMVideoCodecType_HEVC:
    return "hevc"
  case kCMVideoCodecType_VP9:
    return "vp9"
  default:
    return nil
  }
}

/// Creates a video track data object with the given parameters, replacing invalid/zero values with nil.
private func createVideoTrackData(
  index: Int,
  label: String?,
  peakBitRate: Double,
  videoSize: CGSize,
  frameRate: Double,
  codec: String?,
  isSelected: Bool
) -> MediaSelectionVideoTrackData {
  return MediaSelectionVideoTrackData(
    variantIndex: Int64(index),
    label: label,
    bitrate: peakBitRate > 0 ? Int64(peakBitRate) : nil,
    width: videoSize.width > 0 ? Int64(videoSize.width) : nil,
    height: videoSize.height > 0 ? Int64(videoSize.height) : nil,
    frameRate: frameRate > 0 ? frameRate : nil,
    codec: codec,
    isSelected: isSelected)
}
