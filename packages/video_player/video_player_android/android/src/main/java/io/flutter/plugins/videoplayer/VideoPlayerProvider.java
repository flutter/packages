package io.flutter.plugins.videoplayer;

@FunctionalInterface
public interface VideoPlayerProvider {
  VideoPlayer getVideoPlayer(Long playerId);
}
