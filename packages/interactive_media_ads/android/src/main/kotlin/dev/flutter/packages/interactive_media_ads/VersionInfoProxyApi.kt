// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

package dev.flutter.packages.interactive_media_ads

import com.google.ads.interactivemedia.v3.api.VersionInfo

/**
 * ProxyApi implementation for [VersionInfo].
 *
 * <p>This class may handle instantiating native object instances that are attached to a Dart
 * instance or handle method calls on the associated native class or an instance of that class.
 */
class VersionInfoProxyApi(override val pigeonRegistrar: ProxyApiRegistrar) :
    PigeonApiVersionInfo(pigeonRegistrar) {

  override fun pigeon_defaultConstructor(
      majorVersion: Long,
      minorVersion: Long,
      microVersion: Long
  ): VersionInfo {
    return VersionInfo(majorVersion.toInt(), minorVersion.toInt(), microVersion.toInt())
  }

  override fun majorVersion(pigeon_instance: VersionInfo): Long {
    return pigeon_instance.majorVersion.toLong()
  }

  override fun minorVersion(pigeon_instance: VersionInfo): Long {
    return pigeon_instance.minorVersion.toLong()
  }

  override fun microVersion(pigeon_instance: VersionInfo): Long {
    return pigeon_instance.microVersion.toLong()
  }
}
