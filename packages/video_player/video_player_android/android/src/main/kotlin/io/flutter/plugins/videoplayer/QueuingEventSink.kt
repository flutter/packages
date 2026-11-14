// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
package io.flutter.plugins.videoplayer

/**
 * A wrapper for [PigeonEventSink] which can queue messages.
 *
 * It delivers messages immediately when downstream is available, but it queues messages before the
 * delegate event sink is set with setDelegate.
 *
 * This class is not thread-safe. All calls must be done on the same thread or synchronized
 * externally.
 */
internal class QueuingEventSink {
  private var delegate: PigeonEventSink<PlatformVideoEvent?>? = null
  private val eventQueue = ArrayList<Any?>()
  private var done = false

  fun setDelegate(delegate: PigeonEventSink<PlatformVideoEvent?>?) {
    this.delegate = delegate
    maybeFlush()
  }

  fun endOfStream() {
    enqueue(EndOfStreamEvent())
    maybeFlush()
    done = true
  }

  fun error(code: String, message: String?, details: Any?) {
    enqueue(ErrorEvent(code, message, details))
    maybeFlush()
  }

  fun success(event: PlatformVideoEvent?) {
    enqueue(event)
    maybeFlush()
  }

  private fun enqueue(event: Any?) {
    if (done) {
      return
    }
    eventQueue.add(event)
  }

  private fun maybeFlush() {
    if (delegate == null) {
      return
    }
    for (event in eventQueue) {
      if (event is EndOfStreamEvent) {
        delegate!!.endOfStream()
      } else if (event is ErrorEvent) {
        val errorEvent: ErrorEvent = event
        delegate!!.error(errorEvent.code, errorEvent.message, errorEvent.details)
      } else {
        delegate!!.success(event as PlatformVideoEvent?)
      }
    }
    eventQueue.clear()
  }

  internal class EndOfStreamEvent

  private class ErrorEvent(var code: String, var message: String?, var details: Any?)
}
