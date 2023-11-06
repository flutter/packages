/// The mode the controller should operate in.
///
/// This capture mode determines whether the capture session is optimized for
/// video recording or photo capture.
///
/// Defaults to [CaptureMode.video] as the camera plugin configuration is
/// currently geared towards video recording.
enum CaptureMode {
  /// Capture a photo.
  photo,

  /// Capture a video, however this allows the user to take photos while recording.
  video,
}

/// Returns the capture mode as a string
String serializeCaptureMode(CaptureMode captureMode) {
  switch (captureMode) {
    case CaptureMode.photo:
      return 'photo';
    case CaptureMode.video:
      return 'video';
  }
}

/// Returns the capture mode for a given string.
CaptureMode deserializeCaptureMode(String captureMode) {
  switch (captureMode) {
    case 'photo':
      return CaptureMode.photo;
    case 'video':
      return CaptureMode.video;
    default:
      throw ArgumentError('"$captureMode" is not a valid CaptureMode value');
  }
}
