// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import android.view.View
import android.view.ViewGroup

/**
 * ProxyApi implementation for [ViewGroup].
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class ViewGroupProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiViewGroup(pigeonRegistrar) {
  override fun addView(pigeon_instance: ViewGroup, view: View) {
    pigeon_instance.addView(view)
  }

  override fun removeView(pigeon_instance: ViewGroup, view: View) {
    pigeon_instance.removeView(view)
  }
}
