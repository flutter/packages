// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

void main() {
  test('LaunchOptions have default InAppBrowserConfiguration when not passed',
      () {
    expect(
      const LaunchOptions().browserConfiguration,
      const InAppBrowserConfiguration(),
    );
  });

  test('passing non-default InAppBrowserConfiguration to LaunchOptions works',
      () {
    const InAppBrowserConfiguration browserConfiguration =
        InAppBrowserConfiguration(showTitle: true);

    const LaunchOptions launchOptions = LaunchOptions(
      browserConfiguration: browserConfiguration,
    );

    expect(launchOptions.browserConfiguration, browserConfiguration);
  });
}
