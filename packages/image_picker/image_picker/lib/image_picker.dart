// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';

export 'package:image_picker_platform_interface/image_picker_platform_interface.dart'
    show
        CameraDevice,
        ImageSource,
        LostData,
        LostDataResponse,
        MediaSelectionType,
        PickedFile,
        RecentMedia,
        RetrieveType,
        XFile,
        kTypeImage,
        kTypeVideo;

/// Provides an easy way to pick an image/video from the image library,
/// or to take a picture/video with the camera.
class ImagePicker {
  /// The platform interface that drives this plugin
  @visibleForTesting
  static ImagePickerPlatform get platform => ImagePickerPlatform.instance;

  /// Returns an [XFile] object wrapping the image that was picked.
  ///
  /// The returned [XFile] is intended to be used within a single app session.
  /// Do not save the file path and use it across sessions.
  ///
  /// The `source` argument controls where the image comes from. This can
  /// be either [ImageSource.camera] or [ImageSource.gallery].
  ///
  /// Where iOS supports HEIC images, Android 8 and below doesn't. Android 9 and
  /// above only support HEIC images if used in addition to a size modification,
  /// of which the usage is explained below.
  ///
  /// If specified, the image will be at most `maxWidth` wide and
  /// `maxHeight` tall. Otherwise the image will be returned at it's
  /// original width and height.
  /// The `imageQuality` argument modifies the quality of the image, ranging from 0-100
  /// where 100 is the original/max quality. If `imageQuality` is null, the image with
  /// the original quality will be returned. Compression is only supported for certain
  /// image types such as JPEG and on Android PNG and WebP, too. If compression is not
  /// supported for the image that is picked, a warning message will be logged.
  ///
  /// Use `preferredCameraDevice` to specify the camera to use when the `source` is
  /// [ImageSource.camera].
  /// The `preferredCameraDevice` is ignored when `source` is [ImageSource.gallery].
  /// It is also ignored if the chosen camera is not supported on the device.
  /// Defaults to [CameraDevice.rear]. Note that Android has no documented parameter
  /// for an intent to specify if the front or rear camera should be opened, this
  /// function is not guaranteed to work on an Android device.
  ///
  /// Use `requestFullMetadata` (defaults to `true`) to control how much additional
  /// information the plugin tries to get.
  /// If `requestFullMetadata` is set to `true`, the plugin tries to get the full
  /// image metadata which may require extra permission requests on some platforms,
  /// such as `Photo Library Usage` permission on iOS.
  ///
  /// In Android, the MainActivity can be destroyed for various reasons. If that happens, the result will be lost
  /// in this call. You can then call [retrieveLostData] when your app relaunches to retrieve the lost data.
  ///
  /// See also [pickMultiImage] to allow users to select multiple images at once.
  ///
  /// The method could throw [PlatformException] if the app does not have permission to access
  /// the camera or photos gallery, no camera is available, plugin is already in use,
  /// temporary file could not be created (iOS only), plugin activity could not
  /// be allocated (Android only) or due to an unknown error.
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) {
    final imagePickerOptions = ImagePickerOptions.createAndValidate(
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
      preferredCameraDevice: preferredCameraDevice,
      requestFullMetadata: requestFullMetadata,
    );

    return platform.getImageFromSource(source: source, options: imagePickerOptions);
  }

  /// Returns a [List<XFile>] object wrapping the images that were picked.
  ///
  /// The returned [List<XFile>] is intended to be used within a single app session.
  /// Do not save the file path and use it across sessions.
  ///
  /// Where iOS supports HEIC images, Android 8 and below doesn't. Android 9 and above only support HEIC images if used
  /// in addition to a size modification, of which the usage is explained below.
  ///
  /// This method is not supported in iOS versions lower than 14.
  ///
  /// If specified, the images will be at most `maxWidth` wide and
  /// `maxHeight` tall. Otherwise the images will be returned at it's
  /// original width and height.
  ///
  /// The `imageQuality` argument modifies the quality of the images, ranging from 0-100
  /// where 100 is the original/max quality. If `imageQuality` is null, the images with
  /// the original quality will be returned. Compression is only supported for certain
  /// image types such as JPEG and on Android PNG and WebP, too. If compression is not
  /// supported for the image that is picked, a warning message will be logged.
  ///
  /// The `limit` parameter modifies the maximum number of images that can be selected.
  /// This value may be ignored by platforms that cannot support it.
  ///
  /// Use `requestFullMetadata` (defaults to `true`) to control how much additional
  /// information the plugin tries to get.
  /// If `requestFullMetadata` is set to `true`, the plugin tries to get the full
  /// image metadata which may require extra permission requests on some platforms,
  /// such as `Photo Library Usage` permission on iOS.
  ///
  /// The method could throw [PlatformException] if the app does not have permission to access
  /// the camera or photos gallery, no camera is available, plugin is already in use,
  /// temporary file could not be created (iOS only), plugin activity could not
  /// be allocated (Android only) or due to an unknown error.
  ///
  /// See also [pickImage] to allow users to only pick a single image.
  Future<List<XFile>> pickMultiImage({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    int? limit,
    bool requestFullMetadata = true,
  }) async {
    if (limit != null && limit < 1) {
      throw ArgumentError.value(limit, 'limit', 'cannot be lower than 1');
    }
    // limit: 1 would fail MultiImagePickerOptions validation (requires >= 2),
    // so delegate to pickImage which already handles single-image selection.
    if (limit == 1) {
      final XFile? image = await pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
        requestFullMetadata: requestFullMetadata,
      );
      return <XFile>[if (image != null) image];
    }

    final imageOptions = ImageOptions.createAndValidate(
      maxWidth: maxWidth,
      maxHeight: maxHeight,
      imageQuality: imageQuality,
      requestFullMetadata: requestFullMetadata,
    );

    return platform.getMultiImageWithOptions(
      options: MultiImagePickerOptions.createAndValidate(imageOptions: imageOptions, limit: limit),
    );
  }

  /// Returns an [XFile] of the image or video that was picked.
  ///
  /// The image or video can only come from the gallery.
  ///
  /// The returned [XFile] is intended to be used within a single app session.
  /// Do not save the file path and use it across sessions.
  ///
  /// Where iOS supports HEIC images, Android 8 and below doesn't. Android 9 and
  /// above only support HEIC images if used in addition to a size modification,
  /// of which the usage is explained below.
  ///
  /// This method is not supported in iOS versions lower than 14.
  ///
  /// If specified, the image will be at most `maxWidth` wide and
  /// `maxHeight` tall. Otherwise the image will be returned at it's
  /// original width and height.
  ///
  /// The `imageQuality` argument modifies the quality of the image, ranging from 0-100
  /// where 100 is the original/max quality. If `imageQuality` is null, the image with
  /// the original quality will be returned. Compression is only supported for certain
  /// image types such as JPEG and on Android PNG and WebP, too. If compression is not
  /// supported for the image that is picked, a warning message will be logged.
  ///
  /// Use `requestFullMetadata` (defaults to `true`) to control how much additional
  /// information the plugin tries to get.
  /// If `requestFullMetadata` is set to `true`, the plugin tries to get the full
  /// image metadata which may require extra permission requests on some platforms,
  /// such as `Photo Library Usage` permission on iOS.
  ///
  /// The method could throw [PlatformException] if the app does not have permission to access
  /// the photos gallery, plugin is already in use, temporary file could not be
  /// created (iOS only), plugin activity could not be allocated (Android only)
  /// or due to an unknown error.
  ///
  /// If no image or video was picked, the return value is null.
  Future<XFile?> pickMedia({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    bool requestFullMetadata = true,
  }) async {
    final List<XFile> listMedia = await platform.getMedia(
      options: MediaOptions.createAndValidate(
        imageOptions: ImageOptions.createAndValidate(
          maxHeight: maxHeight,
          maxWidth: maxWidth,
          imageQuality: imageQuality,
          requestFullMetadata: requestFullMetadata,
        ),
        allowMultiple: false,
      ),
    );

    return listMedia.isNotEmpty ? listMedia.first : null;
  }

  /// Returns a [List<XFile>] with the images and/or videos that were picked.
  ///
  /// The images and videos come from the gallery.
  ///
  /// The returned [List<XFile>] is intended to be used within a single app session.
  /// Do not save the file paths and use them across sessions.
  ///
  /// Where iOS supports HEIC images, Android 8 and below doesn't. Android 9 and
  /// above only support HEIC images if used in addition to a size modification,
  /// of which the usage is explained below.
  ///
  /// This method is not supported in iOS versions lower than 14.
  ///
  /// If specified, the images will be at most `maxWidth` wide and
  /// `maxHeight` tall. Otherwise the images will be returned at their
  /// original width and height.
  ///
  /// The `imageQuality` argument modifies the quality of the images, ranging from 0-100
  /// where 100 is the original/max quality. If `imageQuality` is null, the images with
  /// the original quality will be returned. Compression is only supported for certain
  /// image types such as JPEG and on Android PNG and WebP, too. If compression is not
  /// supported for the image that is picked, a warning message will be logged.
  ///
  /// The `limit` parameter modifies the maximum number of media that can be selected.
  /// This value may be ignored by platforms that cannot support it.
  ///
  /// Use `requestFullMetadata` (defaults to `true`) to control how much additional
  /// information the plugin tries to get.
  /// If `requestFullMetadata` is set to `true`, the plugin tries to get the full
  /// image metadata which may require extra permission requests on some platforms,
  /// such as `Photo Library Usage` permission on iOS.
  ///
  /// The method could throw [PlatformException] if the app does not have permission to access
  /// the photos gallery, plugin is already in use, temporary file could not be
  /// created (iOS only), plugin activity could not be allocated (Android only)
  /// or due to an unknown error.
  ///
  /// If no images or videos were picked, the return value is an empty list.
  Future<List<XFile>> pickMultipleMedia({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    int? limit,
    bool requestFullMetadata = true,
  }) async {
    if (limit != null && limit < 1) {
      throw ArgumentError.value(limit, 'limit', 'cannot be lower than 1');
    }
    // limit: 1 would fail MediaOptions validation (requires >= 2),
    // so delegate to pickMedia which already handles single-item selection.
    if (limit == 1) {
      final XFile? media = await pickMedia(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
        requestFullMetadata: requestFullMetadata,
      );
      return <XFile>[if (media != null) media];
    }

    return platform.getMedia(
      options: MediaOptions.createAndValidate(
        allowMultiple: true,
        imageOptions: ImageOptions.createAndValidate(
          maxHeight: maxHeight,
          maxWidth: maxWidth,
          imageQuality: imageQuality,
          requestFullMetadata: requestFullMetadata,
        ),
        limit: limit,
      ),
    );
  }

  /// Returns an [XFile] object wrapping the video that was picked.
  ///
  /// The returned [XFile] is intended to be used within a single app session. Do not save the file path and use it across sessions.
  ///
  /// The [source] argument controls where the video comes from. This can
  /// be either [ImageSource.camera] or [ImageSource.gallery].
  ///
  /// The [maxDuration] argument specifies the maximum duration of the captured video when recording from the camera ([ImageSource.camera]),
  /// and is ignored for [ImageSource.gallery]. If no [maxDuration] is specified, the maximum duration will be infinite.
  ///
  /// Use `preferredCameraDevice` to specify the camera to use when the `source` is [ImageSource.camera].
  /// The `preferredCameraDevice` is ignored when `source` is [ImageSource.gallery]. It is also ignored if the chosen camera is not supported on the device.
  /// Defaults to [CameraDevice.rear].
  ///
  /// In Android, the MainActivity can be destroyed for various reasons. If that happens, the result will be lost
  /// in this call. You can then call [retrieveLostData] when your app relaunches to retrieve the lost data.
  ///
  /// The method could throw [PlatformException] if the app does not have permission to access
  /// the camera or photos gallery, no camera is available, plugin is already in use,
  /// temporary file could not be created and video could not be cached (iOS only),
  /// plugin activity could not be allocated (Android only) or due to an unknown error.
  ///
  Future<XFile?> pickVideo({
    required ImageSource source,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    Duration? maxDuration,
  }) {
    return platform.getVideo(
      source: source,
      preferredCameraDevice: preferredCameraDevice,
      maxDuration: maxDuration,
    );
  }

  /// Returns a [List<XFile>] of the videos that were picked.
  ///
  /// The returned [List<XFile>] is intended to be used within a single app
  /// session. Do not save the file path and use it across sessions.
  ///
  /// The videos come from the gallery.
  ///
  /// The [maxDuration] argument specifies the maximum duration of the captured
  /// videos. If no [maxDuration] is specified, the maximum duration will be
  /// infinite. This value may be ignored by platforms that cannot support it.
  ///
  /// The `limit` parameter modifies the maximum number of videos that can be
  /// selected. This value may be ignored by platforms that cannot support it.
  ///
  /// The method can throw a [PlatformException] if the video selection process
  /// fails.
  Future<List<XFile>> pickMultiVideo({Duration? maxDuration, int? limit}) {
    return platform.getMultiVideoWithOptions(
      options: MultiVideoPickerOptions(maxDuration: maxDuration, limit: limit),
    );
  }

  /// Retrieve the lost [XFile] when [pickImage], [pickMultiImage] or [pickVideo] failed because the MainActivity
  /// is destroyed. (Android only)
  ///
  /// Image or video can be lost if the MainActivity is destroyed. And there is no guarantee that the MainActivity is always alive.
  /// Call this method to retrieve the lost data and process the data according to your app's business logic.
  ///
  /// Returns a [LostDataResponse] object if successfully retrieved the lost data. The [LostDataResponse] object can \
  /// represent either a successful image/video selection, or a failure.
  ///
  /// Retrieving the lost data is a one-time operation: once it is returned, the
  /// data is cleared, so subsequent calls return an empty [LostDataResponse]
  /// rather than the same data again.
  ///
  /// Calling this on a non-Android platform will throw [UnimplementedError] exception.
  ///
  /// See also:
  /// * [LostDataResponse], for what's included in the response.
  /// * [Android Activity Lifecycle](https://developer.android.com/reference/android/app/Activity.html), for more information on MainActivity destruction.
  Future<LostDataResponse> retrieveLostData() {
    return platform.getLostData();
  }

  /// Returns true if the current platform implementation supports [source].
  ///
  /// Calling a `pick*` method with a source for which this method
  /// returns `false` will throw an error.
  bool supportsImageSource(ImageSource source) {
    return platform.supportsImageSource(source);
  }

  /// Returns true if the current platform implementation supports
  /// [getRecentMedia].
  ///
  /// Currently only Android and iOS are supported.
  bool supportsRecentMedia() {
    return platform.supportsRecentMedia();
  }

  /// Returns OS-generated thumbnails of the most recent items in the device's
  /// media library, newest first, without showing a picker.
  ///
  /// This is intended for things like showing the latest photo or video on a
  /// gallery button. Use [pickMedia] or the other `pick*` methods to let the
  /// user select items.
  ///
  /// `limit` is the maximum number of items to return, from 1 to 100.
  /// `types` selects whether images, videos, or both are included, and must
  /// not be empty.
  ///
  /// Each [RecentMedia.thumbnail] is a JPEG scaled to fit within
  /// `thumbnailWidth` x `thumbnailHeight` pixels while keeping its aspect
  /// ratio. The platform may return a thumbnail that is somewhat larger or
  /// smaller than requested. [RecentMedia.type] is the type of the original
  /// item, so a video thumbnail has [MediaSelectionType.video].
  ///
  /// This requires read access to the media library, and the app must declare
  /// the corresponding permissions; see the README for details. If the user
  /// has not decided yet, the platform asks for access, so call this method in
  /// response to a user action rather than at startup. If access is denied,
  /// returns an empty list. If the user granted access to only some items,
  /// returns the most recent of those items.
  ///
  /// Thumbnails are written to the app's temporary or cache directory and are
  /// reused by later calls for the same item and size.
  ///
  /// Throws an [ArgumentError] if any argument is out of range. On platforms
  /// where [supportsRecentMedia] returns false, returns an empty list.
  Future<List<RecentMedia>> getRecentMedia({
    int limit = 1,
    Set<MediaSelectionType> types = const <MediaSelectionType>{
      MediaSelectionType.image,
      MediaSelectionType.video,
    },
    int thumbnailWidth = 256,
    int thumbnailHeight = 256,
  }) async {
    final options = RecentMediaOptions.createAndValidate(
      limit: limit,
      types: types,
      thumbnailWidth: thumbnailWidth,
      thumbnailHeight: thumbnailHeight,
    );
    if (!platform.supportsRecentMedia()) {
      return <RecentMedia>[];
    }
    return platform.getRecentMedia(options: options);
  }
}
