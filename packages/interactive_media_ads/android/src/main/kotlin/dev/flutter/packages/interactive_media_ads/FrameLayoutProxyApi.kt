// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import android.widget.FrameLayout

/**
 * ProxyApi implementation for [FrameLayout].
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class FrameLayoutProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiFrameLayout(pigeonRegistrar) {
  override fun pigeon_defaultConstructor(): FrameLayout {
    return FrameLayout(pigeonRegistrar.context)
  }
}
