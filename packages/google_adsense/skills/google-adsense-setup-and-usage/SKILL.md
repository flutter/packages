---
name: google-adsense-setup-and-usage
description: Set up and use the google_adsense plugin for Flutter Web to initialize Google AdSense, trigger H5 Games Ads, and render AdUnitWidget ad slots.
---

# Setting Up and Using google_adsense

`google_adsense` is the official Google AdSense plugin for Flutter Web. It provides APIs to initialize AdSense with your Publisher ID, display H5 Games Ads (interstitial and rewarded ads for web games), and embed responsive display ad units (`AdUnitWidget`).

> **Important**: H5 Games Ads require approval through the [Google AdSense H5 Games Ads beta program](https://adsense.google.com/start/h5-beta/?src=flutter). Ensure your domain and AdSense account are approved to avoid policy issues.

## 1. Installation

Add `google_adsense` to your Flutter Web project's `pubspec.yaml`:

```yaml
dependencies:
  google_adsense: ^0.1.2
```

Or run:

```bash
flutter pub add google_adsense
```

## 2. Platform-Specific Configuration

`google_adsense` is a **Flutter Web only** package.
- Obtain your 16-digit **Publisher ID** (numeric portion of `pub-0123456789012345`) from your [Google AdSense account](https://support.google.com/adsense/answer/105516).
- Call `await adSense.initialize('YOUR_PUBLISHER_ID')` before calling `runApp(...)`. This automatically injects the required AdSense `<script>` tag into your web document.

## 3. Usage and API Examples

### Initializing AdSense and Displaying an Ad Unit (`AdUnitWidget`)

```dart
import 'package:flutter/material.dart';
import 'package:google_adsense/experimental/ad_unit_widget.dart';
import 'package:google_adsense/google_adsense.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AdSense with your 16-digit Publisher ID (without 'pub-' prefix)
  await adSense.initialize('0123456789012345');

  runApp(const MyAdSenseWebApp());
}

class MyAdSenseWebApp extends StatelessWidget {
  const MyAdSenseWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('AdSense for Flutter Web')),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Main Application Content'),
                ),
                // Render a responsive Display Ad Unit
                AdUnitWidget(
                  configuration: AdUnitConfiguration.displayAdUnit(
                    adSlot: '1234567890', // Your AdSense Ad Slot ID
                    adFormat: AdFormat.AUTO,
                    isFullWidthResponsive: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

### Using H5 Games Ads (Ad Placement API)

For web games showing interstitial or rewarded ad breaks between levels or on user request, import `package:google_adsense/h5.dart`:

```dart
import 'package:flutter/foundation.dart';
import 'package:google_adsense/h5.dart';

void showNextLevelInterstitial({required VoidCallback onComplete}) {
  h5Ads.adBreak(
    AdBreakPlacement(
      type: BreakType.next,
      name: 'next-level-break',
      beforeAd: () {
        // Pause game audio and game loop
      },
      afterAd: () {
        // Resume game audio and game loop
      },
      adBreakDone: (AdBreakDonePlacementInfo placementInfo) {
        debugPrint('Ad break finished with status: ${placementInfo.breakStatus}');
        onComplete();
      },
    ),
  );
}
```
