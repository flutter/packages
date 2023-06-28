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
