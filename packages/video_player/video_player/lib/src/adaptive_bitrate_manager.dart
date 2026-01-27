import 'dart:async';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

/// Automatic Adaptive Bitrate Manager for HLS Streaming
/// Manages quality automatically based on buffering and network conditions
class AdaptiveBitrateManager {
  final int playerId;
  final VideoPlayerPlatform _platform;

  late Timer _monitoringTimer;
  int _bufferingCount = 0;
  int _currentQualityLevel = 0;
  DateTime _lastQualityChange = DateTime.now();
  bool _isMonitoring = false;

  // Quality presets (bits per second)
  static const int quality360p = 500000; // 500 kbps
  static const int quality480p = 800000; // 800 kbps
  static const int quality720p = 1200000; // 1.2 Mbps
  static const int quality1080p = 2500000; // 2.5 Mbps

  AdaptiveBitrateManager({
    required this.playerId,
    required VideoPlayerPlatform platform,
  }) : _platform = platform;

  /// Start automatic quality monitoring and adjustment
  Future<void> startAutoAdaptiveQuality() async {
    if (_isMonitoring) return;
    _isMonitoring = true;

    try {
      await _platform.setBandwidthLimit(playerId, 0);
    } catch (e) {
      print('[AdaptiveBitrate] Error starting: $e');
      _isMonitoring = false;
      return;
    }

    _monitoringTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      await _analyzeAndAdjust();
    });
  }

  /// Record a buffering event
  void recordBufferingEvent() {
    if (_isMonitoring) _bufferingCount++;
  }

  /// Analyze network conditions and adjust quality
  Future<void> _analyzeAndAdjust() async {
    // Don't adjust too frequently
    if (DateTime.now().difference(_lastQualityChange).inSeconds < 5) {
      return;
    }

    int newQuality = _selectOptimalQuality();

    if (newQuality != _currentQualityLevel) {
      try {
        await _platform.setBandwidthLimit(playerId, newQuality);
        _currentQualityLevel = newQuality;
        _lastQualityChange = DateTime.now();
        _bufferingCount = 0;
      } catch (e) {
        print('[AdaptiveBitrate] Error adjusting quality: $e');
      }
    }
  }

  /// Select optimal quality based on buffering and network conditions
  int _selectOptimalQuality() {
    // Conservative approach: start high, lower on buffering
    if (_bufferingCount > 5) {
      return quality360p; // Heavy buffering
    }

    if (_bufferingCount > 2) {
      return quality480p; // Moderate buffering
    }

    if (_bufferingCount == 0) {
      return quality1080p; // No buffering - try high quality
    }

    return quality720p; // Default middle quality
  }

  /// Stop automatic quality management
  void dispose() {
    _isMonitoring = false;
    _monitoringTimer.cancel();
  }
}
