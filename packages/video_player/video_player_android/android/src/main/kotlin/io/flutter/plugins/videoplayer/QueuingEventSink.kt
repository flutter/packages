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
  private var delegate: PigeonEventSink<PlatformVideoEvent>? = null
  private val eventQueue = ArrayList<Any>()
  private var done = false

  fun setDelegate(delegate: PigeonEventSink<PlatformVideoEvent>?) {
    this.delegate = delegate
    maybeFlush()
  }

  fun endOfStream() {
    enqueue(EndOfStreamEvent)
    maybeFlush()
    done = true
  }

  fun error(code: String, message: String?, details: Any?) {
    enqueue(ErrorEvent(code, message, details))
    maybeFlush()
  }

  fun success(event: PlatformVideoEvent) {
    enqueue(event)
    maybeFlush()
  }

  private fun enqueue(event: Any) {
    if (done) {
      return
    }
    eventQueue.add(event)
  }

  private fun maybeFlush() {
    delegate?.let {
      for (event in eventQueue) {
        when (event) {
          is EndOfStreamEvent -> {
            it.endOfStream()
          }
          is ErrorEvent -> {
            it.error(event.code, event.message, event.details)
          }
          is PlatformVideoEvent -> {
            it.success(event)
          }
          else -> throw IllegalStateException()
        }
      }
      eventQueue.clear()
    }
  }

  private object EndOfStreamEvent

  private class ErrorEvent(val code: String, val message: String?, val details: Any?)
}
