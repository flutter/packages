// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';

import 'video_ad_example_screen.dart';

/// Entry point for integration tests that require espresso.
@pragma('vm:entry-point')
void integrationTestMain() {
  enableFlutterDriverExtension();
  main();
}

void main() {
  runApp(const MaterialApp(home: HomeScreen()));
}

/// Example widget displaying an Ad before a video.
class HomeScreen extends StatefulWidget {
  /// Constructs an [HomeScreen].
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<(String, String)> _testAdTagUrls = <(String, String)>[
    (
      'Single Inline Linear',
      'https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/single_ad_samples&sz=640x480&cust_params=sample_ct%3Dlinear&ciu_szs=300x250%2C728x90&gdfp_req=1&output=vast&unviewed_position_start=1&env=vp&correlator=',
    ),
    (
      'Pre-, Mid-, Post-roll Singles',
      'https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/vmap_ad_samples&sz=640x480&cust_params=sample_ar%3Dpremidpost&ciu_szs=300x250&gdfp_req=1&ad_rule=1&output=vmap&unviewed_position_start=1&env=vp&cmsid=496&vid=short_onecue&correlator=',
    ),
    (
      'Pre-roll + Bumper',
      'https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/vmap_ad_samples&sz=640x480&cust_params=sample_ar%3Dpreonlybumper&ciu_szs=300x250&gdfp_req=1&ad_rule=1&output=vmap&unviewed_position_start=1&env=vp&correlator=',
    ),
    (
      'Mid-roll ad pod with 2 skippable',
      'https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/vmap_skip_ad_samples&sz=640x480&cust_params=sample_ar%3Dmidskiponly&ciu_szs=300x250&gdfp_req=1&ad_rule=1&output=vmap&unviewed_position_start=1&env=vp&cmsid=496&vid=short_onecue&correlator=',
    ),
  ];

  void _pushVideoAdExampleWithAdTagUrl({
    required String adType,
    required String adTagUrl,
  }) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder:
            (_) => VideoAdExampleScreen(adType: adType, adTagUrl: adTagUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IMA Test App'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
          itemCount: _testAdTagUrls.length,
          separatorBuilder: (_, _) => const SizedBox(height: 50),
          itemBuilder: (_, int index) {
            final (String adType, String adTagUrl) = _testAdTagUrls[index];
            return ElevatedButton(
              onPressed:
                  () => _pushVideoAdExampleWithAdTagUrl(
                    adType: adType,
                    adTagUrl: adTagUrl,
                  ),
              child: Text(adType),
            );
          },
        ),
      ),
    );
  }
}
