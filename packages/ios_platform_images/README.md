# IOS Platform Images

A Flutter plugin to share images between Flutter and iOS.

This allows Flutter to load images from Images.xcassets and iOS code to load
Flutter images.

When loading images from Image.xcassets the device specific variant is chosen
([iOS documentation](https://developer.apple.com/design/human-interface-guidelines/ios/icons-and-images/image-size-and-resolution/)).

|             | iOS   |
|-------------|-------|
| **Support** | 11.0+ |

## Usage

### iOS->Flutter Example

``` dart
// Import package
import 'package:ios_platform_images/ios_platform_images.dart';

Widget build(BuildContext context) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: Image(image: IosPlatformImages.load("flutter")),
      ),
      //..
    ),
  );
}
```

`IosPlatformImages.load` works similarly to [`UIImage(named:)`](https://developer.apple.com/documentation/uikit/uiimage/1624146-imagenamed).

### Flutter->iOS Example

```swift
import ios_platform_images

func makeImage() -> UIImageView {
    let image = UIImage.flutterImageWithName("assets/foo.png")
    return UIImageView(image: image)
}
```
