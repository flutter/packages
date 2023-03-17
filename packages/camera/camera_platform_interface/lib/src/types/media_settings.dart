// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

import 'package:camera_platform_interface/src/types/resolution_preset.dart';

/// recording media settings.
class MediaSettings {
  /// constructor
  const MediaSettings({
    required this.resolutionPreset,
    required this.fps,
    required this.videoBitrate,
    required this.audioBitrate,
  });

  /// Default low quality factory
  factory MediaSettings.low() => const MediaSettings(
        resolutionPreset: ResolutionPreset.low,
        fps: 15,
        videoBitrate: 200000,
        audioBitrate: 32000,
      );

  /// resolution preset
  final ResolutionPreset resolutionPreset;

  /// camera fps
  final int fps;

  /// recording video bitrate
  final int videoBitrate;

  /// recording audio bitrate
  final int audioBitrate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaSettings &&
          runtimeType == other.runtimeType &&
          resolutionPreset == other.resolutionPreset &&
          fps == other.fps &&
          videoBitrate == other.videoBitrate &&
          audioBitrate == other.audioBitrate;

  @override
  int get hashCode =>
      resolutionPreset.hashCode ^ fps.hashCode ^ videoBitrate.hashCode ^ audioBitrate.hashCode;

  @override
  String toString() =>
      'MediaSettings{resolutionPreset: $resolutionPreset, fps: $fps, videoBitrate: $videoBitrate, audioBitrate: $audioBitrate}';
}
