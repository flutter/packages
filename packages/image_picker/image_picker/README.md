# Image Picker plugin for Flutter
<?code-excerpt path-base="example/lib"?>

[![pub package](https://img.shields.io/pub/v/image_picker.svg)](https://pub.dev/packages/image_picker)

A Flutter plugin for iOS and Android for picking images from the image library,
and taking new pictures with the camera.

|             | Android | iOS     | Linux | macOS  | Web                             | Windows     |
|-------------|---------|---------|-------|--------|---------------------------------|-------------|
| **Support** | SDK 21+ | iOS 12+ | Any   | 10.14+ | [See `image_picker_for_web`](https://pub.dev/packages/image_picker_for_web#limitations-on-the-web-platform) | Windows 10+ |

## Setup

### iOS

Starting with version **0.8.1** the iOS implementation uses PHPicker to pick
(multiple) images on iOS 14 or higher.
As a result of implementing PHPicker it becomes impossible to pick HEIC images
on the iOS simulator in iOS 14+. This is a known issue. Please test this on a
real device, or test with non-HEIC images until Apple solves this issue.
[63426347 - Apple known issue](https://www.google.com/search?q=63426347+apple&sxsrf=ALeKk01YnTMid5S0PYvhL8GbgXJ40ZS[…]t=gws-wiz&ved=0ahUKEwjKh8XH_5HwAhWL_rsIHUmHDN8Q4dUDCA8&uact=5)

Add the following keys to your _Info.plist_ file, located in
`<project root>/ios/Runner/Info.plist`:

* `NSPhotoLibraryUsageDescription` - describe why your app needs permission for
the photo library. This is called _Privacy - Photo Library Usage Description_ in
the visual editor.
  * This permission will not be requested if you always pass `false` for
  `requestFullMetadata`, but App Store policy requires including the plist
  entry.
* `NSCameraUsageDescription` - describe why your app needs access to the camera.
This is called _Privacy - Camera Usage Description_ in the visual editor.
* `NSMicrophoneUsageDescription` - describe why your app needs access to the
microphone, if you intend to record videos. This is called
_Privacy - Microphone Usage Description_ in the visual editor.

### Android

Starting with version **0.8.1** the Android implementation support to pick
(multiple) images on Android 4.3 or higher.

No configuration required - the plugin should work out of the box. It is however
highly recommended to prepare for Android killing the application when low on memory. How to prepare for this is discussed in the
[Handling MainActivity destruction on Android](#handling-mainactivity-destruction-on-android)
section.

It is no longer required to add `android:requestLegacyExternalStorage="true"` as
an attribute to the `<application>` tag in AndroidManifest.xml, as
`image_picker` has been updated to make use of scoped storage.

#### Handling MainActivity destruction

When under high memory pressure the Android system may kill the MainActivity of
the application using the image_picker. On Android the image_picker makes use
of the default `Intent.ACTION_GET_CONTENT` or `MediaStore.ACTION_IMAGE_CAPTURE`
intents. This means that while the intent is executing the source application
is moved to the background and becomes eligible for cleanup when the system is
low on memory. When the intent finishes executing, Android will restart the
application. Since the data is never returned to the original call use the
`ImagePicker.retrieveLostData()` method to retrieve the lost data. For example:

<?code-excerpt "readme_excerpts.dart (LostData)"?>
```dart
Future<void> getLostData() async {
  final ImagePicker picker = ImagePicker();
  final LostDataResponse response = await picker.retrieveLostData();
  if (response.isEmpty) {
    return;
  }
  final List<XFile>? files = response.files;
  if (files != null) {
    _handleLostFiles(files);
  } else {
    _handleError(response.exception);
  }
}
```

This check should always be run at startup in order to detect and handle this
case. Please refer to the
[example app](https://pub.dev/packages/image_picker/example) for a more complete
example of handling this flow.

#### Permanently storing images and videos

Images and videos picked using the camera are saved to your application's local
cache, and should therefore be expected to only be around temporarily.
If you require your picked image to be stored permanently, it is your
responsibility to move it to a more permanent location.

#### Android Photo Picker

On Android 13 and above this package uses the
[Android Photo Picker](https://developer.android.com/training/data-storage/shared/photopicker)
. On Android 12 and below use of Android Photo Picker is optional. 
[Learn how to use it](https://pub.dev/packages/image_picker_android).

#### Using `launchMode: singleInstance`

Launching the image picker from an `Activity` with `launchMode: singleInstance`
will always return `RESULT_CANCELED`.
In this launch mode, new activities are created in a separate [Task](https://developer.android.com/guide/components/activities/tasks-and-back-stack).
As activities cannot communicate between tasks, the image picker activity cannot
send back its eventual result to the calling activity.
To work around this problem, consider using `launchMode: singleTask` instead.

### Windows, macOS, and Linux

This plugin currently has limited support for the three desktop platforms,
serving as a wrapper around the [`file_selector`](https://pub.dev/packages/file_selector)
plugin with appropriate file type filters set. Selection modification options,
such as max width and height, are not yet supported.

By default, `ImageSource.camera` is not supported, since unlike on Android and
iOS there is no system-provided UI for taking photos. However, the desktop
implementations allow delegating to a camera handler by setting a
`cameraDelegate` before using `image_picker`, such as in `main()`:

<?code-excerpt "readme_excerpts.dart (CameraDelegate)"?>
```dart
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
// ···
class MyCameraDelegate extends ImagePickerCameraDelegate {
  @override
  Future<XFile?> takePhoto(
      {ImagePickerCameraDelegateOptions options =
          const ImagePickerCameraDelegateOptions()}) async {
    return _takeAPhoto(options.preferredCameraDevice);
  }

  @override
  Future<XFile?> takeVideo(
      {ImagePickerCameraDelegateOptions options =
          const ImagePickerCameraDelegateOptions()}) async {
    return _takeAVideo(options.preferredCameraDevice);
  }
}
// ···
void setUpCameraDelegate() {
  final ImagePickerPlatform instance = ImagePickerPlatform.instance;
  if (instance is CameraDelegatingImagePickerPlatform) {
    instance.cameraDelegate = MyCameraDelegate();
  }
}
```

Once you have set a `cameraDelegate`, `image_picker` calls with
`ImageSource.camera` will work as normal, calling your provided delegate. We
encourage the community to build packages that implement
`ImagePickerCameraDelegate`, to provide options for desktop camera UI.

#### macOS installation

Since the macOS implementation uses `file_selector`, you will need to
add a filesystem access
[entitlement](https://flutter.dev/to/macos-entitlements):

```xml
  <key>com.apple.security.files.user-selected.read-only</key>
  <true/>
```

### Example

<?code-excerpt "readme_excerpts.dart (Pick)"?>
```dart
final ImagePicker picker = ImagePicker();
// Pick an image.
final XFile? image = await picker.pickImage(source: ImageSource.gallery);
// Capture a photo.
final XFile? photo = await picker.pickImage(source: ImageSource.camera);
// Pick a video.
final XFile? galleryVideo =
    await picker.pickVideo(source: ImageSource.gallery);
// Capture a video.
final XFile? cameraVideo = await picker.pickVideo(source: ImageSource.camera);
// Pick multiple images.
final List<XFile> images = await picker.pickMultiImage();
// Pick singe image or video.
final XFile? media = await picker.pickMedia();
// Pick multiple images and videos.
final List<XFile> medias = await picker.pickMultipleMedia();
```

## Migrating to 1.0

Starting with version 0.8.2 of the image_picker plugin, new methods were
added that return `XFile` instances (from the
[cross_file](https://pub.dev/packages/cross_file) package) rather than the
plugin's own `PickedFile` instances. The previous methods were supported through
0.8.9, and removed in 1.0.0.

#### Call the new methods

| Old API | New API |
|---------|---------|
| `PickedFile image = await _picker.getImage(...)` | `XFile image = await _picker.pickImage(...)` |
| `List<PickedFile> images = await _picker.getMultiImage(...)` | `List<XFile> images = await _picker.pickMultiImage(...)` |
| `PickedFile video = await _picker.getVideo(...)` | `XFile video = await _picker.pickVideo(...)` |
| `LostData response = await _picker.getLostData()` | `LostDataResponse response = await _picker.retrieveLostData()` |
