// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The type of the retrieved data in a [LostDataResponse].
enum RetrieveType {
  /// A static picture.
  ///
  /// See [ImagePickerPlatform.pickImage].
  image,

  /// A video.
  ///
  /// See [ImagePickerPlatform.pickVideo].
  video,

  /// Either a video or a static picture.
  ///
  /// See [ImagePickerPlatform.pickMedia].
  media,
}
