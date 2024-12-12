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
  bool _adBreakRequested = false;
  int _coins = 0; // The counter of rewards
  H5ShowAdFn? _showAdFn;
  AdBreakDonePlacementInfo? _lastPlacementInfo;

  @override
  void initState() {
    super.initState();
    h5GamesAds.adConfig(
      AdConfigParameters(
        sound: SoundEnabled.off,
        // Force `on` so there's an Ad immediately preloaded.
        preloadAdBreaks: PreloadAdBreaks.on,
        onReady: _onH5Ready,
      ),
    );
  }

  void _onH5Ready() {
    setState(() {
      _h5Ready = true;
    });
  }

  void _requestInterstitialAd() {
    h5GamesAds.adBreak(
      AdBreakPlacement.interstitial(
        type: BreakType.browse,
        name: 'test-interstitial-ad',
      ),
    );
  }

  void _requestRewardedAd() {
    h5GamesAds.adBreak(
      AdBreakPlacement.rewarded(
        name: 'test-rewarded-ad',
        beforeReward: _beforeReward,
        adViewed: _adViewed,
        adDismissed: _adDismissed,
        afterAd: _afterAd,
        adBreakDone: _adBreakDone,
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
      _coins++;
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

  void _adBreakDone(AdBreakDonePlacementInfo info) {
    setState(() {
      _lastPlacementInfo = info;
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton.icon(
              onPressed: _h5Ready ? _requestInterstitialAd : null,
              label: const Text('Show Interstitial Ad'),
              icon: const Icon(Icons.play_circle_outline_rounded),
            ),
            const Divider(),
            PaddedCard(
              children: <Widget>[
                const Text(
                  '🪙 Available coins:',
                ),
                Text(
                  '$_coins',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                TextButton.icon(
                  onPressed:
                      _h5Ready && !adBreakAvailable ? _requestRewardedAd : null,
                  label: const Text('Prepare Reward'),
                  icon: const Icon(Icons.download_rounded),
                ),
                TextButton.icon(
                  onPressed: _showAdFn,
                  label: const Text('Watch Ad For 1 Coin'),
                  icon: const Text('🪙'),
                ),
              ],
            ),
            Text(
              'Rewarded Ad Status:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text('Requested? $_adBreakRequested'),
            Text('Available? $adBreakAvailable'),
            Text('Last Status: ${_lastPlacementInfo?.breakStatus}'),
          ],
        ),
      ),
    );
  }
}

class PaddedCard extends StatelessWidget {
  final List<Widget> children;

  PaddedCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          children: children,
        ),
      ),
    );
  }
}
