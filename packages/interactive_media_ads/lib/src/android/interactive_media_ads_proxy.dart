import 'interactive_media_ads.g.dart';

/// Handles constructing objects and calling static methods for the Android
/// Interactive Media Ads native library.
///
/// This class provides dependency injection for the implementations of the
/// platform interface classes. Improving the ease of unit testing and/or
/// overriding the underlying Android classes.
///
/// By default each function calls the default constructor of the class it
/// intends to return.
class InteractiveMediaAdsProxy {
  /// Constructs a [InteractiveMediaAdsProxy].
  const InteractiveMediaAdsProxy({
    this.newFrameLayout = FrameLayout.new,
    this.newVideoView = VideoView.new,
  });

  /// Creates a new [FrameLayout].
  final FrameLayout Function() newFrameLayout;

  /// Creates a new [VideoView].
  final VideoView Function({
    void Function(VideoView, MediaPlayer)? onPrepared,
    void Function(VideoView, MediaPlayer)? onCompletion,
    required void Function(VideoView, MediaPlayer, int, int) onError,
  }) newVideoView;
}
