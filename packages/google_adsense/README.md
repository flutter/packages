# google_adsense
[Google AdSense](https://adsense.google.com/intl/en_us/start/) plugin for Flutter Web

This package initializes AdSense on your website and provides an ad unit `Widget` that can be configured and placed in the desired location in your Flutter web app UI, without having to directly modify the HTML markup of the app directly.

## Disclaimer: Early Access ⚠️
This package is currently in early access and is provided as-is. While it's open source and publicly available, it's likely that you'll need to make additional customizations and configurations to fully integrate it with your Flutter Web App.
Please express interest joining Early Access program using [this form](https://docs.google.com/forms/d/e/1FAIpQLSdN6aOwVkaxGdxbVQFVZ_N4_UCBkuWYa-cS4_rbU_f1jK10Tw/viewform)

## Installation
run `flutter pub add google_adsense`

## Usage

#### Setup your AdSense account
1. [Make sure your site's pages are ready for AdSense](https://support.google.com/adsense/answer/7299563?hl=en&sjid=5790642343077592212-EU&visit_id=638657100661171978-1373860041&ref_topic=1319756&rd=1)
2. [Create your AdSense account](https://support.google.com/adsense/answer/10162?hl=en&sjid=5790642343077592212-EU&visit_id=638657100661171978-1373860041&ref_topic=1250103&rd=1)

#### Initialize AdSense
To start displaying ads, initialize the AdSense with your [client/publisher ID](https://support.google.com/adsense/answer/105516?hl=en&sjid=5790642343077592212-EU) (only use numbers).
<?code-excerpt "example/lib/main.dart (init)"?>
```dart
import 'package:google_adsense/google_adsense.dart';

void main() {
  adSense.initialize(
      '0556581589806023'); // TODO: Replace with your own AdClient ID
  runApp(const MyApp());
}

```
You are all set to start displaying [Auto ads](https://support.google.com/adsense/answer/9261805?hl=en)!

#### Create ad unit in Google AdSense UI 
To use ad unit `Widget`, create [ad units](https://support.google.com/adsense/answer/9183549?hl=en&ref_topic=9183242&sjid=5790642343077592212-EU) in your AdSense account

#### Display ad unit Widget
1. Translate HTML snippet into package APIs

| HTML attribute                      | Package API                                           |
|-------------------------------------|-------------------------------------------------------|
| `data-ad-client`                    | `AdUnitParams.AD_CLIENT`                              |
| `data-ad-slot`                      | `AdUnitParams.AD_SLOT`                                |
| `data-ad-format`                    | `AdUnitParams.AD_FORMAT`                              |
| `data-full-width-responsive`        | `AdUnitParams.FULL_WIDTH_RESPONSIVE`                  |
| `data-ad-layout-key`                | `AdUnitParams.AD_LAYOUT_KEY`                          |
| `data-ad-layout`                    | `AdUnitParams.AD_LAYOUT`                              |
| `data-matched-content-ui-type`      | `AdUnitParams.MATCHED_CONTENT_UI_TYPE`                |
| `data-matched-content-rows-num`     | `AdUnitParams.MATCHED_CONTENT_ROWS_NUM`               |
| `data-matched-content-columns-num`  | `AdUnitParams.MATCHED_CONTENT_COLUMNS_NUM`            |

For example:
```html
<ins class="adsbygoogle"
     style="display:block"
     data-ad-client="ca-pub-0556581589806023"
     data-ad-slot="4773943862"
     data-ad-format="auto"
     data-full-width-responsive="true"></ins>
<script>
     (adsbygoogle = window.adsbygoogle || []).push({});
</script>
```
Translates into: 
```dart
adSense.initialize('0556581589806023');
```
and
<?code-excerpt "example/lib/main.dart (adUnit)"?>
```dart
    adSense.adUnit(AdUnitConfiguration.displayAdUnit(
  adSlot: '4773943862', // TODO: Replace with your own AdSlot ID
  adFormat: AdFormat
      .AUTO, // Remove AdFormat to make ads limited by height
))
```

#### Customize ad unit Widget
To [modify your responsive ad code](https://support.google.com/adsense/answer/9183363?hl=en&ref_topic=9183242&sjid=11551379421978541034-EU):
1. Make sure your modifications are not breaking AdSense policies (e.g. avoid driving [unnatural attention to ads](https://support.google.com/adsense/answer/1346295?sjid=11551379421978541034-EU#Unnatural_attention_to_ads))
2. Use Flutter instruments for [adaptive and responsive design](https://docs.flutter.dev/ui/adaptive-responsive)

For example, when not using responsive `AdFormat` it is recommended to wrap adUnit widget in the `Container` with width and/or height constraints.
Note some [policies and restrictions](https://support.google.com/adsense/answer/9185043?hl=en#:~:text=Policies%20and%20restrictions) related to ad unit sizing:

<?code-excerpt "example/lib/main.dart (constraints)"?>
```dart
Container(
  constraints: const BoxConstraints(maxHeight: 100),
  padding: const EdgeInsets.only(bottom: 10),
  child: adSense.adUnit(AdUnitConfiguration.displayAdUnit(
    adSlot: '4773943862', // TODO: Replace with your own AdSlot ID
    // adFormat: AdFormat.AUTO, // Not using AdFormat to make ad unit respect height constraint
  )),
),
```
## Testing and common errors

### Failed to load resource: the server responded with a status of 400
Make sure to replace `your_ad_client_id` and `your_ad_slot_id` with the relevant values

### Failed to load resource: the server responded with a status of 403
1. When happening in **testing/staging** environment it is likely related to the fact that ads are only filled when requested from an authorized domain. If you are testing locally and running your web app on `localhost`, you need to:
   1. Set custom domain name on localhost by creating a local DNS record that would point `127.0.0.1` and/or `localhost` to `your-domain.com`. On mac/linux machines this can be achieved by adding the following records to you /etc/hosts file:
        `127.0.0.1	your-domain.com`
        `localhost   your-domain.com`
   2. Specify additional run arguments in IDE by editing `Run/Debug Configuration` or by passing them directly to `flutter run` command:  
       `--web-port=8080`  
       `--web-hostname=your-domain.com`
2. When happening in **production** it might be that your domain was not yet approved or was disapproved. Login to your AdSense account to check your domain approval status

### Ad unfilled  

There is no deterministic way to make sure your ads are 100% filled even when testing. Some of the way to increase the fill rate:


- Add AD_TEST parameter with value `true`  
- Make sure AD_FORMAT is `auto` (default setting)
- Make sure FULL_WIDTH_RESPONSIVE is `true` (default setting)
- Try resizing the window or making sure that ad unit Widget width is less than ~1300px 
