// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';

class MapConfiguration {
  MapConfiguration({this.cloudMapId});
  final String? cloudMapId;
}

class MapTypeStyle {}

class MapOptions {
  List<MapTypeStyle>? styles;
  String? mapId;
}

MapOptions configurationAndStyleToGmapsOptions(
    MapConfiguration configuration, List<MapTypeStyle> styles) {
  final MapOptions options = MapOptions();
  if (configuration.cloudMapId == null) {
    options.styles = styles;
  }
  options.mapId = configuration.cloudMapId;
  return options;
}

void main() {
  test('sets styles only when cloudMapId is null', () {
    final List<MapTypeStyle> styles = <MapTypeStyle>[MapTypeStyle()];
    final MapConfiguration configWithId = MapConfiguration(cloudMapId: 'id');
    final MapConfiguration configWithoutId = MapConfiguration();

    final MapOptions optionsWithId =
        configurationAndStyleToGmapsOptions(configWithId, styles);
    final MapOptions optionsWithoutId =
        configurationAndStyleToGmapsOptions(configWithoutId, styles);

    expect(optionsWithId.styles, isNull);
    expect(optionsWithId.mapId, 'id');
    expect(optionsWithoutId.styles, styles);
    expect(optionsWithoutId.mapId, isNull);
  });
}
