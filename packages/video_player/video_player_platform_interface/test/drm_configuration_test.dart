// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

/// A stand-in for the DRM configuration subclasses that implementation packages
/// provide.
class _FakeDrmConfiguration extends VideoDrmConfiguration {
  const _FakeDrmConfiguration();
}

void main() {
  test('DataSource has no DRM configuration by default', () {
    final dataSource = DataSource(
      sourceType: DataSourceType.network,
      uri: 'https://example.com/video.m3u8',
    );

    expect(dataSource.drmConfiguration, isNull);
  });

  test('DataSource passes through its DRM configuration', () {
    const VideoDrmConfiguration configuration = _FakeDrmConfiguration();
    final dataSource = DataSource(
      sourceType: DataSourceType.network,
      uri: 'https://example.com/video.m3u8',
      drmConfiguration: configuration,
    );

    expect(dataSource.drmConfiguration, same(configuration));
  });
}
