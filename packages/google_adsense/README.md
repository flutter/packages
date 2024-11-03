# google_adsense
[Google AdSense](https://adsense.google.com/intl/en_us/start/) plugin for Flutter Web

This package initializes AdSense on your website and provides an `AdUnitWidget` that can be configured and placed in the desired location in your Flutter web app UI, without having to directly modify the HTML markup of the app directly.

## Installation
run `flutter pub add google_adsense`

## Usage

#### Setup your AdSense account
1. [Make sure your site's pages are ready for AdSense](https://support.google.com/adsense/answer/7299563?hl=en&sjid=5790642343077592212-EU&visit_id=638657100661171978-1373860041&ref_topic=1319756&rd=1)
2. [Create your AdSense account](https://support.google.com/adsense/answer/10162?hl=en&sjid=5790642343077592212-EU&visit_id=638657100661171978-1373860041&ref_topic=1250103&rd=1)
3. (Optionally) To use `AdUnitWidget`, create [ad units](https://support.google.com/adsense/answer/9183549?hl=en&ref_topic=9183242&sjid=5790642343077592212-EU) in your AdSense account

#### Initialize AdSense
To start displaying ads, initialize the AdSense with your [client/publisher ID](https://support.google.com/adsense/answer/105516?hl=en&sjid=5790642343077592212-EU) (only use numbers).
<?code-excerpt "example/lib/main.dart (init)"?>
```dart
import 'package:google_adsense/google_adsense.dart';

void main() {
  adSense.initialize('your_ad_client_id');
  runApp(const MyApp());
}

```
You are all set to start displaying [Auto ads](https://support.google.com/adsense/answer/9261805?hl=en)!
#### Display AdUnitWidget
<?code-excerpt "example/lib/main.dart (adUnit)"?>
```dart
adSense.adUnit(
    adSlot: 'your_ad_slot_id',
    isAdTest: true,
    adUnitParams: <String, String>{
      AdUnitParams.AD_FORMAT: 'auto',
      AdUnitParams.FULL_WIDTH_RESPONSIVE: 'true',
    },
    cssText:
        'border: 5px solid red; display: block; padding: 20px'),
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
- Try resizing the window or making sure that adUnitWidget width is less than ~1300px 
