// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: flutter_style_todos

import 'package:flutter/material.dart';

import 'package:google_adsense/google_adsense.dart';
import 'package:google_adsense/h5.dart';

void main() async {
  await adSense.initialize('0123456789012345');
  runApp(const MyApp());
}

/// The main app.
class MyApp extends StatelessWidget {
  /// Constructs a [MyApp]
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

/// The home screen
class MyHomePage extends StatefulWidget {
  /// Constructs a [HomeScreen]
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _h5Ready = false;
  H5ShowAdFn? _showAdFn;
  bool _adBreakRequested = false;
  int _adsViewed = 0;

  @override
  void initState() {
    super.initState();
    h5GamesAds.adConfig(
      AdConfigParameters(
        sound: SoundEnabled.off,
        onReady: _onH5Ready,
      ),
    );
  }

  void _onH5Ready() {
    setState(() {
      _h5Ready = true;
    });
  }

  void _requestRewardedAd() {
    h5GamesAds.adBreak(
      AdBreakPlacement.rewarded(
        name: 'test-rewarded-ad',
        beforeReward: _beforeReward,
        adViewed: _adViewed,
        adDismissed: _adDismissed,
        afterAd: _afterAd,
      ),
    );
    setState(() {
      _adBreakRequested = true;
    });
  }

  void _beforeReward(H5ShowAdFn showAdFn) {
    setState(() {
      _showAdFn = showAdFn;
    });
  }

  void _adViewed() {
    setState(() {
      _showAdFn = null;
      _adsViewed++;
    });
  }

  void _adDismissed() {
    setState(() {
      _showAdFn = null;
    });
  }

  void _afterAd() {
    setState(() {
      _showAdFn = null;
      _adBreakRequested = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool adBreakAvailable = _showAdFn != null;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('H5 Games for Flutter demo app'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'H5 Games Ads status:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text('Ad Break requested? $_adBreakRequested'),
          Text('Ad Break available? $adBreakAvailable'),
          Text('Rewards obtained: $_adsViewed'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextButton.icon(
                onPressed:
                    _h5Ready &&  !adBreakAvailable ? _requestRewardedAd : null,
                label: const Text('Prepare Rewarded ad'),
                icon: const Icon(Icons.download_rounded),
              ),
              TextButton.icon(
                onPressed: _showAdFn,
                label: const Text('Watch Ad For 1 Coin!'),
                icon: const Icon(Icons.play_circle_outline_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
