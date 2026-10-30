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

  test('WidevineDrmConfiguration has no license headers by default', () {
    final configuration = WidevineDrmConfiguration(
      licenseUri: Uri.parse('https://example.com/license'),
    );

    expect(configuration.licenseHeaders, isEmpty);
  });

  test('WidevineDrmConfiguration can be passed on a DataSource', () {
    final configuration = WidevineDrmConfiguration(
      licenseUri: Uri.parse('https://example.com/license'),
      licenseHeaders: const <String, String>{'Authorization': 'token'},
    );
    final dataSource = DataSource(
      sourceType: DataSourceType.network,
      uri: 'https://example.com/video.mpd',
      drmConfiguration: configuration,
    );

    expect(
      dataSource.drmConfiguration,
      isA<WidevineDrmConfiguration>()
          .having(
            (WidevineDrmConfiguration c) => c.licenseUri,
            'licenseUri',
            Uri.parse('https://example.com/license'),
          )
          .having(
            (WidevineDrmConfiguration c) => c.licenseHeaders,
            'licenseHeaders',
            <String, String>{'Authorization': 'token'},
          ),
    );
  });
}
