# AdSense initialization

AdSense initialization is the same both for H5 Games Ads and the Ad Unit Widget.

To initialize AdSense:

## Setup your AdSense account

1. [Make sure your site's pages are ready for AdSense](https://support.google.com/adsense/answer/7299563)
2. [Create your AdSense account](https://support.google.com/adsense/answer/10162)

## Configure your Publisher ID

To start displaying ads, initialize AdSense with your
[Publisher ID](https://support.google.com/adsense/answer/105516) (only use numbers).

<?code-excerpt "example/lib/main.dart (init)"?>
```dart
import 'package:google_adsense/google_adsense.dart';

void main() async {
  // Call `initialize` with your Publisher ID (pub-0123456789012345)
  // (See: https://support.google.com/adsense/answer/105516)
  await adSense.initialize('0123456789012345');

  runApp(const MyApp());
}
```
