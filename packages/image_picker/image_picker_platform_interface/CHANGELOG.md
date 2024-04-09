## 2.10.0

* Adds limit parameter to `MediaOptions` and `MultiImagePickerOptions`.

## 2.9.4

* Updates minimum supported SDK version to Flutter 3.19/Dart 3.3.
* Removes a few deprecated API usages.

## 2.9.3

* Updates minimum required plugin_platform_interface version to 2.1.7.

## 2.9.2

* Updates minimum supported SDK version to Flutter 3.10/Dart 3.0.
* Fixes new lint warnings.

## 2.9.1

* Adds pub topics to package metadata.
* Updates minimum supported SDK version to Flutter 3.7/Dart 2.19.

## 2.9.0

* Formally deprecates all methods that have been replaced with newer variants.

## 2.8.0

* Adds `getMedia` method.

## 2.7.0

* Adds `CameraDelegatingImagePickerPlatform` as a base class for platform
  implementations that don't support `ImageSource.camera`, but allow for an-
  implementation to be provided at the application level via implementation
  of `CameraDelegatingImagePickerPlatform`.
* Adds `supportsImageSource` to check source support at runtime.

## 2.6.4

* Adds compatibility with `http` 1.0.
* Updates minimum supported SDK version to Flutter 3.3/Dart 2.18.
* Aligns Dart and Flutter SDK constraints.

## 2.6.3

* Updates links for the merge of flutter/plugins into flutter/packages.
* Updates minimum Flutter version to 3.0.

## 2.6.2

* Updates imports for `prefer_relative_imports`.
* Updates minimum Flutter version to 2.10.
* Fixes avoid_redundant_argument_values lint warnings and minor typos.

## 2.6.1

* Exports new types added for `getMultiImageWithOptions` in 2.6.0.

## 2.6.0

* Deprecates `getMultiImage` in favor of a new method `getMultiImageWithOptions`.
    * Adds `requestFullMetadata` option that allows disabling extra permission requests
      on certain platforms.
    * Moves optional image picking parameters to `MultiImagePickerOptions` class.

## 2.5.0

* Deprecates `getImage` in favor of a new method `getImageFromSource`.
    * Adds `requestFullMetadata` option that allows disabling extra permission requests
      on certain platforms.
    * Moves optional image picking parameters to `ImagePickerOptions` class.
* Minor fixes for new analysis options.

## 2.4.4

* Internal code cleanup for stricter analysis options.

## 2.4.3

* Removes dependency on `meta`.

## 2.4.2

* Update to use the `verify` method introduced in plugin_platform_interface 2.1.0.

## 2.4.1

* Reverts the changes from 2.4.0, which was a breaking change that
  was incorrectly marked as a non-breaking change.

## 2.4.0

* Add `forceFullMetadata` option to `pickImage`.
  * To keep this non-breaking `forceFullMetadata` defaults to `true`, so the plugin tries
   to get the full image metadata which may require extra permission requests on certain platforms.
  * If `forceFullMetadata` is set to `false`, the plugin fetches the image in a way that reduces
   permission requests from the platform (e.g on iOS the plugin won’t ask for the `NSPhotoLibraryUsageDescription` permission).

## 2.3.0

* Updated `LostDataResponse` to include a `files` property, in case more than one file was recovered.

## 2.2.0

* Added new methods that return `XFile` (from `package:cross_file`)
  * `getImage` (will deprecate `pickImage`)
  * `getVideo` (will deprecate `pickVideo`)
  * `getMultiImage` (will deprecate `pickMultiImage`)

_`PickedFile` will also be marked as deprecated in an upcoming release._

## 2.1.0

* Add `pickMultiImage` method.

## 2.0.1

* Update platform_plugin_interface version requirement.

## 2.0.0

* Migrate to null safety.
* Breaking Changes:
    * Removed the deprecated methods: `ImagePickerPlatform.retrieveLostDataAsDartIoFile`,`ImagePickerPlatform.pickImagePath` and `ImagePickerPlatform.pickVideoPath`.
    * Removed deprecated class: `LostDataResponse`.

## 1.1.6

* Fix test asset file location.

## 1.1.5

* Update Flutter SDK constraint.

## 1.1.4

* Pass `Uri`s to `package:http` methods, instead of strings, in preparation for a major version update in `http`.

## 1.1.3

* Update documentation of `pickImage()` regarding HEIC images.

## 1.1.2

* Update documentation of `pickImage()` regarding compression support for specific image types.

## 1.1.1

* Update documentation of getImage() about Android's disability to preference front/rear camera.

## 1.1.0

* Introduce PickedFile type for the new API.

## 1.0.1

* Update lower bound of dart dependency to 2.1.0.

## 1.0.0

* Initial release.
