package io.flutter.plugins.videoplayer;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.EventChannel;

final class VideoPlayerEventCallbacks implements VideoPlayerCallbacks {
    private final EventChannel.EventSink eventSink;

    static VideoPlayerEventCallbacks bindTo(EventChannel eventChannel) {
        QueuingEventSink eventSink = new QueuingEventSink();
        eventChannel.setStreamHandler(
                new EventChannel.StreamHandler() {
                    @Override
                    public void onListen(Object arguments, EventChannel.EventSink events) {
                        eventSink.setDelegate(events);
                    }

                    @Override
                    public void onCancel(Object arguments) {
                        eventSink.setDelegate(null);
                    }
                });
        return VideoPlayerEventCallbacks.withSink(eventSink);
    }

    static VideoPlayerEventCallbacks withSink(EventChannel.EventSink eventSink) {
        return new VideoPlayerEventCallbacks(eventSink);
    }

    private VideoPlayerEventCallbacks(EventChannel.EventSink eventSink) {
        this.eventSink = eventSink;
    }

    @Override
    public void onInitialized(int width, int height, long durationInMs, @Nullable Integer rotationCorrectionInDegrees) {
        Map<String, Object> event = new HashMap<>();
        event.put("event", "initialized");
        event.put("width", width);
        event.put("height", height);
        event.put("duration", durationInMs);
        if (rotationCorrectionInDegrees != null) {
            event.put("rotationCorrection", rotationCorrectionInDegrees);
        }
        eventSink.success(event);
    }

    @Override
    public void onBufferingStart() {
        Map<String, Object> event = new HashMap<>();
        event.put("event", "bufferingStart");
        eventSink.success(event);
    }

    @Override
    public void onBufferingUpdate(long bufferedPosition) {
        // iOS supports a list of buffered ranges, so we send as a list with a single range.
        Map<String, Object> event = new HashMap<>();
        event.put("values", Collections.singletonList(bufferedPosition));
        eventSink.success(event);
    }

    @Override
    public void onBufferingEnd() {
        Map<String, Object> event = new HashMap<>();
        event.put("event", "bufferingEnd");
        eventSink.success(event);
    }

    @Override
    public void onCompleted() {
        Map<String, Object> event = new HashMap<>();
        event.put("event", "completed");
        eventSink.success(event);
    }

    @Override
    public void onError(@NonNull String code, @Nullable String message, @Nullable Object details) {
        eventSink.error(code, message, details);
    }

    @Override
    public void onIsPlayingStateUpdate(boolean isPlaying) {
        Map<String, Object> event = new HashMap<>();
        event.put("isPlaying", isPlaying);
        eventSink.success(event);
    }
}
