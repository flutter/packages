# google_adsense

[Google AdSense](https://adsense.google.com/start/) plugin for Flutter Web.

This package provides a way to initialize and use AdSense on your Flutter Web app.
It includes libraries for the following products:

* [H5 Games Ads](https://adsense.google.com/start/h5-games-ads/) (beta)
* (Experimental) [AdSense Ad Unit](https://support.google.com/adsense/answer/9183549) Widget

## AdSense initialization

AdSense initialization is the same both for H5 Games Ads and the Ad Unit Widget.

To initialize AdSense:

### Setup your AdSense account

1. [Make sure your site's pages are ready for AdSense](https://support.google.com/adsense/answer/7299563)
2. [Create your AdSense account](https://support.google.com/adsense/answer/10162)

### Configure your Publisher ID

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

## H5 Games Ads

The `h5.dart` library provides a way to use the
[AdSense Ad Placement API](https://developers.google.com/ad-placement)
to easily display ads in games and other interactive content on the web.

H5 Games Ads offers high-performing formats:

* [Interstitials](https://developers.google.com/ad-placement/apis#interstitials):
  Full-screen ads that are displayed at natural breaks in your game,
  such as between levels. Users can choose to either click these ads or return
  to your game.
* [Rewarded ads](https://developers.google.com/ad-placement/apis#rewarded_ads):
  Ads that users can choose to interact with in exchange for in-game rewards.

H5 Games Ads formats support display ads, TrueView and Bumper video ads.

### Disclaimer: Beta product ⚠️
H5 Games Ads is a beta product.

Apply to the [H5 Games Ads Beta](https://adsense.google.com/start/h5-beta/)
program to integrate ads in your H5 games. We will notify you when you are
approved to start implementing ads on your games.

#### Import the H5 Games Ads client

<?code-excerpt "example/lib/h5.dart (import-h5)"?>
```dart
import 'package:google_adsense/h5.dart';
```

This provides an `h5GamesAds` object with two methods: `adBreak` to request ads,
and `adConfig` to configure the ads that are going to be served.

#### Displaying an Interstitial Ad

To display an Interstitial Ad, call the `adBreak` method with an
`AdBreakPlacement.interstitial`:

<?code-excerpt "example/lib/h5.dart (interstitial)"?>
```dart
h5GamesAds.adBreak(
  AdBreakPlacement.interstitial(
    type: BreakType.browse,
    name: 'test-interstitial-ad',
    adBreakDone: _interstitialBreakDone,
  ),
);
```

##### Break Types

The following Break Types are available for `interstitial` ads:


| `BreakType` | Description |
|-------------|-------------|
| `start`     | Before the app flow starts (after UI has rendered) |
| `pause`     | Shown while the app is paused (games) |
| `next`      | Ad shown when user is navigating to the next screen |
| `browse`    | Shown while the user explores options |

See the Ad Placement API reference on
[Interstitials](https://developers.google.com/ad-placement/apis#interstitials)
for a full explanation of all the available parameters.

#### Displaying a Rewarded Ad

To display a Rewarded Ad, call the `adBreak` method with an
`AdBreakPlacement.rewarded`:

<?code-excerpt "example/lib/h5.dart (rewarded)"?>
```dart
h5GamesAds.adBreak(
  AdBreakPlacement.rewarded(
    name: 'test-rewarded-ad',
    beforeReward: _beforeReward,
    adViewed: _adViewed,
    adDismissed: _adDismissed,
    afterAd: _afterAd,
    adBreakDone: _rewardedBreakDone,
  ),
);
```

If a Rewarded ad is available, the `beforeReward` callback will be called with a
`showAdFn` function that you can call to show the Ad when the player wants to
claim a reward.

When the user fully watches the ad, the `adViewed` callback will be called, and
the reward should be granted.

If the user dismisses the ad before they're eligible for a reward, the
`adDismissed` callback will be called instead.

See the Ad Placmeent API reference on
[Rewarded ads](https://developers.google.com/ad-placement/apis#rewarded_ads)
for a full explanation of all the available parameters, and the
[call sequence for a rewarded ad](https://developers.google.com/ad-placement/apis#call_sequence_for_a_rewarded_ad).

#### The `adBreakDone` callback

Note that a call to `adBreak` might not show an ad at all. It simply declares a
place where an ad **could** be shown.

If the API does not have an ad to show it will not call the various before/after
callbacks that are configured. However, if you provide an `adBreakDone` callback,
this will **always** be called, even if an ad is not shown. This allows you to
perform any additional work needed for the placement, such as logging analytics.

The `adBreakDone` function takes as argument an `AdBreakDonePlacementInfo` object,
which contains a `breakStatus` property. See the `BreakStatus` enum docs for
more information about the possible values.

#### Configuring Ads

The `adConfig` function communicates the game's current configuration to the Ad
Placement API. It is used to tune the way it preloads ads and to filter the kinds
of ads it requests so they're suitable.

You can call `adConfig` with an `AdConfigParameters` object at any time, like
this:

<?code-excerpt "example/lib/h5.dart (adConfig)"?>
```dart
h5GamesAds.adConfig(
  AdConfigParameters(
    sound: SoundEnabled.off,
    // Force `on` so there's an Ad immediately preloaded.
    preloadAdBreaks: PreloadAdBreaks.on,
    onReady: _onH5Ready,
  ),
);
```

See the Ad Placement API reference on
[adConfig](https://developers.google.com/ad-placement/apis/adconfig)
for a full explanation of all the available parameters.


## AdSense

The `experimental/ad_unit_widget.dart` library provides an ad unit `Widget` that
can be configured and placed in the desired location in your Flutter web app UI,
without having to directly modify the HTML markup of the app directly.

### Disclaimer: Early Access ⚠️
This package is currently in early access and is provided as-is. While it's open
source and publicly available, it's likely that you'll need to make additional
customizations and configurations to fully integrate it with your Flutter Web App.

Please express interest joining Early Access program using [this form](https://docs.google.com/forms/d/e/1FAIpQLSdN6aOwVkaxGdxbVQFVZ_N4_UCBkuWYa-cS4_rbU_f1jK10Tw/viewform)

### Usage

First, initialize AdSense (see above).

#### Import the widget

Import the **experimental** `AdUnitWidget` from the package:

<?code-excerpt "example/lib/ad_unit_widget.dart (import-widget)"?>
```dart
import 'package:google_adsense/experimental/ad_unit_widget.dart';
```

#### Displaying Auto Ads

In order to start displaying [Auto ads](https://support.google.com/adsense/answer/9261805):

1. Configure this feature in your AdSense Console.

Auto ads should start showing just with the call to `initialize`, when available.

If you want to display ad units within your app content, continue to the next step:

#### Display ad units (`AdUnitWidget`)

To display an Ad unit in your Flutter application:

1. Create [ad units](https://support.google.com/adsense/answer/9183549)
   in your AdSense account. This will provide an HTML snippet, which you need to
   _translate_ to Dart.
2. The data-attributes from the generated snippet can be translated to Dart with the `AdUnitConfiguration` object.
Their Dart name is created as follows:

- The `data-` prefix is removed.
- `kebab-case` becomes `camelCase`

The only exception to this is `data-ad-client`, that is passed to `adSense.initialize`,
instead of through an `AdUnitConfiguration` object.

For example, the snippet below:

```html
<ins class="adsbygoogle"
     style="display:block"
     data-ad-client="ca-pub-0123456789012345"
     data-ad-slot="1234567890"
     data-ad-format="auto"
     data-full-width-responsive="true"></ins>
<script>
     (adsbygoogle = window.adsbygoogle || []).push({});
</script>
```

translates into:

<?code-excerpt "example/lib/ad_unit_widget.dart (adUnit)"?>
```dart
    AdUnitWidget(
  configuration: AdUnitConfiguration.displayAdUnit(
    // TODO: Replace with your Ad Unit ID
    adSlot: '1234567890',
    // Remove AdFormat to make ads limited by height
    adFormat: AdFormat.AUTO,
  ),
),
```

##### `AdUnitConfiguration` constructors

In addition to `displayAdUnit`, there's specific constructors for each supported
Ad Unit type. See the table below:

| Ad Unit Type   | `AdUnitConfiguration` constructor method   |
|----------------|--------------------------------------------|
| Display Ads    | `AdUnitConfiguration.displayAdUnit(...)`   |
| In-feed Ads    | `AdUnitConfiguration.inFeedAdUnit(...)`    |
| In-article Ads | `AdUnitConfiguration.inArticleAdUnit(...)` |
| Multiplex Ads  | `AdUnitConfiguration.multiplexAdUnit(...)` |


##### `AdUnitWidget` customizations

To [modify your responsive ad code](https://support.google.com/adsense/answer/9183363?hl=en&ref_topic=9183242&sjid=11551379421978541034-EU):
1. Make sure to follow [AdSense policies](https://support.google.com/adsense/answer/1346295?hl=en&sjid=18331098933308334645-EU&visit_id=638689380593964621-4184295127&ref_topic=1271508&rd=1)
2. Use Flutter instruments for [adaptive and responsive design](https://docs.flutter.dev/ui/adaptive-responsive)

For example, when not using responsive `AdFormat` it is recommended to wrap adUnit widget in the `Container` with width and/or height constraints.
Note some [policies and restrictions](https://support.google.com/adsense/answer/9185043?hl=en#:~:text=Policies%20and%20restrictions) related to ad unit sizing:

<?code-excerpt "example/lib/ad_unit_widget.dart (constraints)"?>
```dart
Container(
  constraints:
      const BoxConstraints(maxHeight: 100, maxWidth: 1200),
  padding: const EdgeInsets.only(bottom: 10),
  child: AdUnitWidget(
    configuration: AdUnitConfiguration.displayAdUnit(
      // TODO: Replace with your Ad Unit ID
      adSlot: '1234567890',
      // Do not use adFormat to make ad unit respect height constraint
      // adFormat: AdFormat.AUTO,
    ),
  ),
),
```
### Testing and common errors

#### Failed to load resource: the server responded with a status of 400
Make sure to set correct values to adSlot and adClient arguments

#### Failed to load resource: the server responded with a status of 403
1. When happening in **testing/staging** environment it is likely related to the fact that ads are only filled when requested from an authorized domain. If you are testing locally and running your web app on `localhost`, you need to:
   1. Set custom domain name on localhost by creating a local DNS record that would point `127.0.0.1` and/or `localhost` to `your-domain.com`. On mac/linux machines this can be achieved by adding the following records to you /etc/hosts file:
        `127.0.0.1	your-domain.com`
        `localhost   your-domain.com`
   2. Specify additional run arguments in IDE by editing `Run/Debug Configuration` or by passing them directly to `flutter run` command:
       `--web-port=8080`
       `--web-hostname=your-domain.com`
2. When happening in **production** it might be that your domain was not yet approved or was disapproved. Login to your AdSense account to check your domain approval status

#### Ad unfilled

There is no deterministic way to make sure your ads are 100% filled even when testing. Some of the way to increase the fill rate:
- Ensure your ad units are correctly configured in AdSense
- Try setting `adTest` parameter to `true`
- Try setting AD_FORMAT to `auto` (default setting)
- Try setting FULL_WIDTH_RESPONSIVE to `true` (default setting)
- Try resizing the window or making sure that ad unit Widget width is less than ~1200px

## Support

For any questions or support, please reach out to your Google representative or
leverage the [AdSense Help Center](https://support.google.com/adsense#topic=3373519).

For problem with this package, please
[create a Github issue](https://github.com/flutter/flutter/issues/new?assignees=&labels=&projects=&template=9_first_party_packages.yml).
