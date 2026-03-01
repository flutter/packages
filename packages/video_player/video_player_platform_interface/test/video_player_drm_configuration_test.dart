// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

void main() {
  test('WidevineDrmConfiguration defaults licenseHeaders to empty map', () {
    final configuration = WidevineDrmConfiguration(
      licenseUri: Uri.parse('https://license.example.com/widevine'),
    );

    expect(configuration.licenseHeaders, isEmpty);
  });

  test('FairPlayDrmConfiguration defaults licenseHeaders to empty map', () {
    final configuration = FairPlayDrmConfiguration(
      certificateUri: Uri.parse('https://license.example.com/cert'),
      licenseUri: Uri.parse('https://license.example.com/fairplay'),
    );

    expect(configuration.licenseHeaders, isEmpty);
    expect(configuration.contentId, isNull);
  });

  test('DataSource stores drmConfiguration', () {
    final configuration = FairPlayDrmConfiguration(
      certificateUri: Uri.parse('https://license.example.com/cert'),
      licenseUri: Uri.parse('https://license.example.com/fairplay'),
      contentId: 'asset-content-id',
    );
    final dataSource = DataSource(
      sourceType: DataSourceType.network,
      uri: 'https://example.com/video.m3u8',
      drmConfiguration: configuration,
    );

    expect(dataSource.drmConfiguration, same(configuration));
  });
}
