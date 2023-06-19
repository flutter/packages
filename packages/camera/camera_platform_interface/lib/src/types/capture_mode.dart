/// The mode of capture to use when taking a picture or video.
enum CaptureMode {
  /// Capture a photo.
  photo,

  /// Capture a video, however this allows the user to take photos while recording.
  video,
}

/// Returns the capture mode as a String.
///
String serializeCaptureMode(CaptureMode captureMode) {
  switch (captureMode) {
    case CaptureMode.photo:
      return 'photo';
    case CaptureMode.video:
      return 'video';
  }
}

/// Returns the capture mode for a given String.
///
CaptureMode deserializeCaptureMode(String str) {
  switch (str) {
    case 'photo':
      return CaptureMode.photo;
    case 'video':
      return CaptureMode.video;
    default:
      throw ArgumentError('"$str" is not a valid CaptureMode value');
  }
}
