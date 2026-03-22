import 'dart:async';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

/// Manages adaptive bitrate selection for HLS/DASH streaming.
///
/// Monitors buffering events and adjusts the maximum bandwidth limit
/// to help the native player select appropriate quality variants.
///
/// This acts as a supervisory controller on top of the native player's
/// own ABR logic (ExoPlayer's [AdaptiveTrackSelection] on Android,
/// AVFoundation on iOS). It forces quality down via [setBandwidthLimit]
/// when persistent buffering is detected, and relaxes the limit when
/// playback stabilizes.
class AdaptiveBitrateManager {
  /// Creates an [AdaptiveBitrateManager] for the given [playerId].
  ///
  /// The optional [clock] parameter is exposed for testing and defaults
  /// to [DateTime.now].
  AdaptiveBitrateManager({
    required this.playerId,
    required VideoPlayerPlatform platform,
    @visibleForTesting DateTime Function()? clock,
  }) : _platform = platform,
       _clock = clock ?? DateTime.now;

  /// The player ID this manager controls.
  final int playerId;
  final VideoPlayerPlatform _platform;
  final DateTime Function() _clock;

  Timer? _monitoringTimer;
  int _bufferingCount = 0;
  int _currentBandwidthLimit = qualityUnlimited;
  late DateTime _lastQualityChange = _clock();
  bool _isMonitoring = false;

  /// Bandwidth cap for 360p quality (~500 kbps).
  static const int quality360p = 500000;

  /// Bandwidth cap for 480p quality (~800 kbps).
  static const int quality480p = 800000;

  /// Bandwidth cap for 720p quality (~1.2 Mbps).
  static const int quality720p = 1200000;

  /// Bandwidth cap for 1080p quality (~2.5 Mbps).
  static const int quality1080p = 2500000;

  /// No bandwidth limit — lets the native player choose freely.
  static const int qualityUnlimited = 0;

  static const Duration _monitorInterval = Duration(seconds: 3);
  static const Duration _qualityChangeCooldown = Duration(seconds: 5);

  /// Buffering count decay factor applied each monitoring cycle.
  ///
  /// This allows recovery to higher quality after transient buffering.
  static const double _bufferingDecayFactor = 0.7;

  /// Starts automatic quality monitoring and adjustment.
  ///
  /// Removes any existing bandwidth limit and begins periodic analysis.
  /// Safe to call multiple times — subsequent calls are no-ops.
  Future<void> startAutoAdaptiveQuality() async {
    if (_isMonitoring) {
      return;
    }
    _isMonitoring = true;

    try {
      await _platform.setBandwidthLimit(playerId, qualityUnlimited);
    } catch (e) {
      _isMonitoring = false;
      return;
    }

    _monitoringTimer = Timer.periodic(_monitorInterval, (_) {
      _analyzeAndAdjust();
    });
  }

  /// Records a buffering event from the player.
  ///
  /// Called by [VideoPlayerController] when a [bufferingStart] event occurs.
  void recordBufferingEvent() {
    if (_isMonitoring) {
      _bufferingCount++;
    }
  }

  /// Analyzes recent buffering history and adjusts the bandwidth limit.
  Future<void> _analyzeAndAdjust() async {
    if (_clock().difference(_lastQualityChange) < _qualityChangeCooldown) {
      return;
    }

    final int newLimit = _selectOptimalBandwidth();

    // Apply decay so transient buffering doesn't permanently pin quality low.
    _bufferingCount = (_bufferingCount * _bufferingDecayFactor).floor();

    if (newLimit != _currentBandwidthLimit) {
      try {
        await _platform.setBandwidthLimit(playerId, newLimit);
        _currentBandwidthLimit = newLimit;
        _lastQualityChange = _clock();
      } catch (e) {
        // Silently ignore errors during auto-adjustment.
      }
    }
  }

  /// Selects optimal bandwidth based on recent buffering frequency.
  int _selectOptimalBandwidth() {
    if (_bufferingCount > 5) {
      return quality360p;
    }
    if (_bufferingCount > 3) {
      return quality480p;
    }
    if (_bufferingCount > 1) {
      return quality720p;
    }
    if (_bufferingCount > 0) {
      return quality1080p;
    }
    return qualityUnlimited;
  }

  /// Stops monitoring and releases resources.
  void dispose() {
    _isMonitoring = false;
    _monitoringTimer?.cancel();
    _monitoringTimer = null;
  }
}
