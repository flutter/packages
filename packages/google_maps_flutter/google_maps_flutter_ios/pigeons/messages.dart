// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  objcHeaderOut: 'ios/Classes/messages.g.h',
  objcSourceOut: 'ios/Classes/messages.g.m',
  objcOptions: ObjcOptions(prefix: 'FGM'),
  copyrightHeader: 'pigeons/copyright.txt',
))

/// Pigeon equivalent of GMSTileLayer properties.
class PlatformTileLayer {
  PlatformTileLayer({
    required this.visible,
    required this.fadeIn,
    required this.opacity,
    required this.zIndex,
  });

  final bool visible;
  final bool fadeIn;
  final double opacity;
  final int zIndex;
}

/// Possible outcomes of launching a URL.
class PlatformZoomRange {
  PlatformZoomRange({required this.min, required this.max});

  final double min;
  final double max;
}

/// Inspector API only intended for use in integration tests.
@HostApi()
abstract class MapsInspectorApi {
  bool areBuildingsEnabled();
  bool areRotateGesturesEnabled();
  bool areScrollGesturesEnabled();
  bool areTiltGesturesEnabled();
  bool areZoomGesturesEnabled();
  bool isCompassEnabled();
  bool isMyLocationButtonEnabled();
  bool isTrafficEnabled();
  @ObjCSelector('getInfoForTileOverlayWithIdentifier:')
  PlatformTileLayer? getTileOverlayInfo(String tileOverlayId);
  @ObjCSelector('zoomRange')
  PlatformZoomRange getZoomRange();
}
