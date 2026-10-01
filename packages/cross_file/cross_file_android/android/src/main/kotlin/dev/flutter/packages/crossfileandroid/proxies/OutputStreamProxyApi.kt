// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.crossfileandroid.proxies

import dev.flutter.packages.crossfileandroid.ProxyApiRegistrar
import java.io.OutputStream

/**
 * ProxyApi implementation for [OutputStream].
 *
 * This class may handle instantiating native object instances that are attached to a Dart instance
 * or handle method calls on the associated native class or an instance of that class.
 */
class OutputStreamProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiOutputStream(pigeonRegistrar) {
    override fun write(pigeon_instance: OutputStream, bytes: ByteArray) {
        pigeon_instance.write(bytes)
    }

    override fun close(pigeon_instance: OutputStream) {
        pigeon_instance.close()
    }

    override fun flush(pigeon_instance: OutputStream) {
        pigeon_instance.flush()
    }

}
