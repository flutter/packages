
Wrapper of the AdSense Ad Placement API to be used in Dart and Flutter apps.
This Wrapper targets only the WEB platform.

## Features

To view the complete API, please check the official [AdSense website](https://developers.google.com/ad-placement/apis)

## Getting started

Add this package as a dependency on `pubspec.yaml` and import the library and the `ad_placement_api.dart` file.
This package supports interacting with the Ad Placement API after it's already loaded. Please remember to include the appropriate adsense js files to the page before using this package.


## Usage

When you import the library inside a file, you'll have access to the singleton object `adPlacementApi`, which will have wrappers to both of the global functions that the Ad Placement API exposes: adBreak and adConfig.

Example
```
import 'package:google_adsense_ad_placement_api/ad_placement_api.dart';

void main (){
    ...
    adPlacementApi.adBreak(
        name: "rewarded-example",
        type: BreakType.reward,
    );
    ...
}

```

## Testing

Use `dart run script/tool/bin/flutter_plugin_tools.dart test --packages google_adsense_ad_placement_api --platform chrome` to test.
You need to specify a web platform to be able to test the JS Interop library.