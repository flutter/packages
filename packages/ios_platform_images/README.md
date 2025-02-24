# iOS Platform Images

## To be discontinued

**This project will be discontinued on April 30, 2025**, and will not receive further updates after that point. Community members interested in collaborating on a community-maintained fork can coordinate in [this issue](https://github.com/flutter/flutter/issues/162961).

---

A Flutter plugin to share images between Flutter and iOS.

This allows Flutter to load images from Images.xcassets and iOS code to load
Flutter images.

When loading images from Image.xcassets the device specific variant is chosen
([iOS documentation](https://developer.apple.com/design/human-interface-guidelines/ios/icons-and-images/image-size-and-resolution/)).

|             | iOS   |
|-------------|-------|
| **Support** | 12.0+ |

## Usage

### iOS->Flutter Example

<?code-excerpt "example/lib/main.dart (Usage)"?>
```dart
// "flutter" is a resource in Assets.xcassets.
final Image xcassetImage = Image(
  image: IosPlatformImages.load('flutter'),
  semanticLabel: 'Flutter logo',
);
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
