// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package com.example.android_kotlin_unit_tests

import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MessageCodec
import io.flutter.plugin.common.StandardMessageCodec
import java.nio.ByteBuffer
import java.util.ArrayList


internal class EchoBinaryMessenger(private val codec: MessageCodec<Any?>): BinaryMessenger {
    override fun send(channel: String, message: ByteBuffer?) {
        // Method not implemented because this messenger is just for echoing.
    }

    override fun send(
        channel: String,
        message: ByteBuffer?,
        callback: BinaryMessenger.BinaryReply?
    ) {
        message?.rewind()
        val args = codec.decodeMessage(message) as ArrayList<*>
        val replyData = codec.encodeMessage(args[0])
        replyData?.position(0)
        callback?.reply(replyData)
    }

    override fun setMessageHandler(
        channel: String,
        handler: BinaryMessenger.BinaryMessageHandler?
    ) {
        // Method not implemented because this messenger is just for echoing.
    }

}
