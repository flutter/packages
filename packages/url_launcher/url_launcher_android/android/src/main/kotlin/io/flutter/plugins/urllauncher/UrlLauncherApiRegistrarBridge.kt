// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package io.flutter.plugins.urllauncher

import io.flutter.embedding.engine.plugins.FlutterPlugin

/**
 * Bridges [UrlLauncherApiRegistrar]'s Kotlin default parameters for the Java implementation in this
 * package, since the generated registrar isn't annotated with `@JvmOverloads` and its default
 * instance name is private.
 */
internal object UrlLauncherApiRegistrarBridge {
  private val registrar = UrlLauncherApiRegistrar()

  fun register(api: UrlLauncherApi, binding: FlutterPlugin.FlutterPluginBinding) {
    registrar.register(api, binding)
  }

  fun unregister(api: UrlLauncherApi, binding: FlutterPlugin.FlutterPluginBinding) {
    registrar.unregister(api, binding)
  }
}
