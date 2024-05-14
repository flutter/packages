// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import android.widget.FrameLayout

class FrameLayoutProxyApi(pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiFrameLayout(pigeonRegistrar) {
  override fun pigeon_defaultConstructor(): FrameLayout {
    return FrameLayout((pigeonRegistrar as ProxyApiRegistrar).context)
  }
}
