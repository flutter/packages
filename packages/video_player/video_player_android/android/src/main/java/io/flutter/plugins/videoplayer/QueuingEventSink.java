// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.videoplayer;

import java.util.ArrayList;

/**
 * A wrapper for {@link PigeonEventSink} which can queue messages.
 *
 * <p>It delivers messages immediately when downstream is available, but it queues messages before
 * the delegate event sink is set with setDelegate.
 *
 * <p>This class is not thread-safe. All calls must be done on the same thread or synchronized
 * externally.
 */
final class QueuingEventSink {
  private PigeonEventSink<PlatformVideoEvent> delegate;
  private final ArrayList<Object> eventQueue = new ArrayList<>();
  private boolean done = false;

  public void setDelegate(PigeonEventSink<PlatformVideoEvent> delegate) {
    this.delegate = delegate;
    maybeFlush();
  }

  public void endOfStream() {
    enqueue(new EndOfStreamEvent());
    maybeFlush();
    done = true;
  }

  public void error(String code, String message, Object details) {
    enqueue(new ErrorEvent(code, message, details));
    maybeFlush();
  }

  public void success(PlatformVideoEvent event) {
    enqueue(event);
    maybeFlush();
  }

  private void enqueue(Object event) {
    if (done) {
      return;
    }
    eventQueue.add(event);
  }

  private void maybeFlush() {
    if (delegate == null) {
      return;
    }
    for (Object event : eventQueue) {
      if (event instanceof EndOfStreamEvent) {
        delegate.endOfStream();
      } else if (event instanceof ErrorEvent) {
        ErrorEvent errorEvent = (ErrorEvent) event;
        delegate.error(errorEvent.code, errorEvent.message, errorEvent.details);
      } else {
        delegate.success((PlatformVideoEvent) event);
      }
    }
    eventQueue.clear();
  }

  static class EndOfStreamEvent {}

  private static class ErrorEvent {
    String code;
    String message;
    Object details;

    ErrorEvent(String code, String message, Object details) {
      this.code = code;
      this.message = message;
      this.details = details;
    }
  }
}
