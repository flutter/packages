// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
// Autogenerated from Pigeon, do not edit directly.
// See also: https://pub.dev/packages/pigeon
@file:Suppress("UNCHECKED_CAST", "ArrayInDataClass")

import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.common.StandardMethodCodec
import java.io.ByteArrayOutputStream
import java.nio.ByteBuffer

private fun deepEqualsEventChannelMessages(a: Any?, b: Any?): Boolean {
  if (a is ByteArray && b is ByteArray) {
    return a.contentEquals(b)
  }
  if (a is IntArray && b is IntArray) {
    return a.contentEquals(b)
  }
  if (a is LongArray && b is LongArray) {
    return a.contentEquals(b)
  }
  if (a is DoubleArray && b is DoubleArray) {
    return a.contentEquals(b)
  }
  if (a is Array<*> && b is Array<*>) {
    return a.size == b.size && a.indices.all { deepEqualsEventChannelMessages(a[it], b[it]) }
  }
  if (a is List<*> && b is List<*>) {
    return a.size == b.size && a.indices.all { deepEqualsEventChannelMessages(a[it], b[it]) }
  }
  if (a is Map<*, *> && b is Map<*, *>) {
    return a.size == b.size &&
        a.all {
          (b as Map<Any?, Any?>).containsKey(it.key) &&
              deepEqualsEventChannelMessages(it.value, b[it.key])
        }
  }
  return a == b
}

/**
 * Generated class from Pigeon that represents data sent in messages. This class should not be
 * extended by any user class outside of the generated file.
 */
sealed class PlatformEvent
/** Generated class from Pigeon that represents data sent in messages. */
data class IntEvent(val data: Long) : PlatformEvent() {
  companion object {
    fun fromList(pigeonVar_list: List<Any?>): IntEvent {
      val data = pigeonVar_list[0] as Long
      return IntEvent(data)
    }
  }

  fun toList(): List<Any?> {
    return listOf(
        data,
    )
  }

  override fun equals(other: Any?): Boolean {
    if (other !is IntEvent) {
      return false
    }
    if (this === other) {
      return true
    }
    return deepEqualsEventChannelMessages(toList(), other.toList())
  }

  override fun hashCode(): Int = toList().hashCode()
}

/** Generated class from Pigeon that represents data sent in messages. */
data class StringEvent(val data: String) : PlatformEvent() {
  companion object {
    fun fromList(pigeonVar_list: List<Any?>): StringEvent {
      val data = pigeonVar_list[0] as String
      return StringEvent(data)
    }
  }

  fun toList(): List<Any?> {
    return listOf(
        data,
    )
  }

  override fun equals(other: Any?): Boolean {
    if (other !is StringEvent) {
      return false
    }
    if (this === other) {
      return true
    }
    return deepEqualsEventChannelMessages(toList(), other.toList())
  }

  override fun hashCode(): Int = toList().hashCode()
}

private open class EventChannelMessagesPigeonCodec : StandardMessageCodec() {
  override fun readValueOfType(type: Byte, buffer: ByteBuffer): Any? {
    return when (type) {
      129.toByte() -> {
        return (readValue(buffer) as? List<Any?>)?.let { IntEvent.fromList(it) }
      }
      130.toByte() -> {
        return (readValue(buffer) as? List<Any?>)?.let { StringEvent.fromList(it) }
      }
      else -> super.readValueOfType(type, buffer)
    }
  }

  override fun writeValue(stream: ByteArrayOutputStream, value: Any?) {
    when (value) {
      is IntEvent -> {
        stream.write(129)
        writeValue(stream, value.toList())
      }
      is StringEvent -> {
        stream.write(130)
        writeValue(stream, value.toList())
      }
      else -> super.writeValue(stream, value)
    }
  }
}

val EventChannelMessagesPigeonMethodCodec = StandardMethodCodec(EventChannelMessagesPigeonCodec())

private class EventChannelMessagesPigeonStreamHandler<T>(
    val wrapper: EventChannelMessagesPigeonEventChannelWrapper<T>
) : EventChannel.StreamHandler {
  var pigeonSink: PigeonEventSink<T>? = null

  override fun onListen(p0: Any?, sink: EventChannel.EventSink) {
    pigeonSink = PigeonEventSink<T>(sink)
    wrapper.onListen(p0, pigeonSink!!)
  }

  override fun onCancel(p0: Any?) {
    pigeonSink = null
    wrapper.onCancel(p0)
  }
}

interface EventChannelMessagesPigeonEventChannelWrapper<T> {
  open fun onListen(p0: Any?, sink: PigeonEventSink<T>) {}

  open fun onCancel(p0: Any?) {}
}

class PigeonEventSink<T>(private val sink: EventChannel.EventSink) {
  fun success(value: T) {
    sink.success(value)
  }

  fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
    sink.error(errorCode, errorMessage, errorDetails)
  }

  fun endOfStream() {
    sink.endOfStream()
  }
}

abstract class StreamEventsStreamHandler :
    EventChannelMessagesPigeonEventChannelWrapper<PlatformEvent> {
  companion object {
    fun register(
        messenger: BinaryMessenger,
        streamHandler: StreamEventsStreamHandler,
        instanceName: String = ""
    ) {
      var channelName: String =
          "dev.flutter.pigeon.pigeon_example_package.EventChannelMethods.streamEvents"
      if (instanceName.isNotEmpty()) {
        channelName += ".$instanceName"
      }
      val internalStreamHandler =
          EventChannelMessagesPigeonStreamHandler<PlatformEvent>(streamHandler)
      EventChannel(messenger, channelName, EventChannelMessagesPigeonMethodCodec)
          .setStreamHandler(internalStreamHandler)
    }
  }
}
