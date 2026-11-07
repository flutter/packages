// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:cross_file/cross_file.dart';

import '../types/types.dart';

/// The interface that implementations of image_picker must implement.
abstract base class ImagePickerPlatform {
  /// The default instance of [ImagePickerPlatform] to use.
  static ImagePickerPlatform? instance;

  /// Returns a [List<XFile>] with the images and/or videos that were picked.
  /// The images and videos come from the gallery.
  ///
  /// Where iOS supports HEIC images, Android 8 and below doesn't. Android 9 and
  /// above only support HEIC images if used in addition to a size modification,
  /// of which the usage is explained below.
  ///
  /// In Android, the MainActivity can be destroyed for various reasons.
  /// If that happens, the result will be lost in this call. You can then
  /// call [getLostData] when your app relaunches to retrieve the lost data.
  ///
  /// If no images or videos were picked, the return value is an empty list.
  Future<List<XFile>> pickMedia({required MediaPickerOptions options}) {
    throw UnimplementedError('pickMedia() has not been implemented.');
  }

  /// Returns a [XFile] containing the video that was picked.
  ///
  /// The [source] argument controls where the video comes from. This can
  /// be either [ImageSource.camera] or [ImageSource.gallery].
  ///
  /// The [maxDuration] argument specifies the maximum duration of the captured video. If no [maxDuration] is specified,
  /// the maximum duration will be infinite.
  ///
  /// Use `preferredCameraDevice` to specify the camera to use when the `source` is [ImageSource.camera].
  /// The `preferredCameraDevice` is ignored when `source` is [ImageSource.gallery]. It is also ignored if the chosen camera is not supported on the device.
  /// Defaults to [CameraDevice.rear].
  ///
  /// In Android, the MainActivity can be destroyed for various reasons. If that happens, the result will be lost
  /// in this call. You can then call [getLostData] when your app relaunches to retrieve the lost data.
  ///
  /// If no images were picked, the return value is null.
  Future<XFile?> pickVideo({
    required ImageSource source,
    VideoPickerOptions options = const VideoPickerOptions(),
  }) {
    throw UnimplementedError('pickVideo() has not been implemented.');
  }

  /// Retrieves any previously picked files, that were lost due to the MainActivity being destroyed. (Android only)
  ///
  /// Image or video can be lost if the MainActivity is destroyed. And there is no guarantee that the MainActivity is
  /// always alive. Call this method to retrieve the lost data and process the data according to your APP's business logic.
  ///
  /// Returns a [LostDataResponse] object if successfully retrieved the lost data. The [LostDataResponse] object can
  /// represent either a successful image/video selection, or a failure.
  ///
  /// Retrieving the lost data is a one-time operation: implementations must
  /// clear the stored data once it has been returned, so that subsequent calls
  /// return an empty [LostDataResponse] rather than the same data again.
  ///
  /// Calling this on a non-Android platform will throw [UnimplementedError] exception.
  ///
  /// See also:
  /// * [LostDataResponse], for what's included in the response.
  /// * [Android Activity Lifecycle](https://developer.android.com/reference/android/app/Activity.html), for more
  ///   information on MainActivity destruction.
  Future<LostDataResponse> getLostData() {
    throw UnimplementedError('getLostData() has not been implemented.');
  }

  /// Returns an [XFile] with the image that was picked.
  ///
  /// The `source` argument controls where the image comes from. This can
  /// be either [ImageSource.camera] or [ImageSource.gallery].
  ///
  /// The `options` argument controls additional settings that can be used when
  /// picking an image. See [ImagePickerOptions] for more details.
  ///
  /// Where iOS supports HEIC images, Android 8 and below doesn't. Android 9 and
  /// above only support HEIC images if used in addition to a size modification,
  /// of which the usage is explained in [ImagePickerOptions].
  ///
  /// In Android, the MainActivity can be destroyed for various reasons. If that
  /// happens, the result will be lost in this call. You can then call [getLostData]
  /// when your app relaunches to retrieve the lost data.
  ///
  /// If no images were picked, the return value is null.
  Future<XFile?> pickImage({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) {
    throw UnimplementedError('pickImage() has not been implemented.');
  }

  /// Returns a [List<XFile>] with the images that were picked.
  ///
  /// The images come from the [ImageSource.gallery].
  ///
  /// The `options` argument controls additional settings that can be used when
  /// picking an image. See [MultiImagePickerOptions] for more details.
  ///
  /// If no images were picked, returns an empty list.
  Future<List<XFile>> pickMultiImage({
    MultiImagePickerOptions options = const MultiImagePickerOptions(),
  }) async {
    throw UnimplementedError('pickMultiImage() has not been implemented.');
  }

  /// Returns a [List<XFile>] with the videos that were picked.
  ///
  /// The videos come from the [ImageSource.gallery].
  ///
  /// The `options` argument controls additional settings that can be used when
  /// picking a video. See [MultiVideoPickerOptions] for more details.
  ///
  /// If no videos were picked, returns an empty list.
  Future<List<XFile>> pickMultiVideo({
    MultiVideoPickerOptions options = const MultiVideoPickerOptions(),
  }) {
    throw UnimplementedError('pickMultiVideo() has not been implemented.');
  }

  /// Returns true if the implementation supports [source].
  ///
  /// Defaults to true for the original image sources, `gallery` and `camera`,
  /// for backwards compatibility.
  bool supportsImageSource(ImageSource source) {
    return source == ImageSource.gallery || source == ImageSource.camera;
  }
}

/// A base class for an [ImagePickerPlatform] implementation that does not
/// directly support [ImageSource.camera], but supports delegating to a
/// provided [ImagePickerCameraDelegate].
abstract base class CameraDelegatingImagePickerPlatform extends ImagePickerPlatform {
  /// A delegate to respond to calls that use [ImageSource.camera].
  ///
  /// When it is null, attempting to use [ImageSource.camera] will throw a
  /// [StateError].
  ImagePickerCameraDelegate? cameraDelegate;

  @override
  bool supportsImageSource(ImageSource source) {
    if (source == ImageSource.camera) {
      return cameraDelegate != null;
    }
    return super.supportsImageSource(source);
  }

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    if (source == ImageSource.camera) {
      final ImagePickerCameraDelegate? delegate = cameraDelegate;
      if (delegate == null) {
        throw StateError(
          'This implementation of ImagePickerPlatform requires a '
          '"cameraDelegate" in order to use ImageSource.camera',
        );
      }
      return delegate.takePhoto(options: options);
    }
    return super.pickImage(source: source, options: options);
  }

  @override
  Future<XFile?> pickVideo({
    required ImageSource source,
    VideoPickerOptions options = const VideoPickerOptions(),
  }) async {
    if (source == ImageSource.camera) {
      final ImagePickerCameraDelegate? delegate = cameraDelegate;
      if (delegate == null) {
        throw StateError(
          'This implementation of ImagePickerPlatform requires a '
          '"cameraDelegate" in order to use ImageSource.camera',
        );
      }
      return delegate.takeVideo(options: options);
    }
    return super.pickVideo(source: source, options: options);
  }
}
