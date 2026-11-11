// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import '../../image_picker_platform_interface.dart';

/// Specifies options for [ImagePickerPlatform.getRecentMedia].
@immutable
class RecentMediaOptions {
  /// Construct a new RecentMediaOptions instance.
  const RecentMediaOptions({
    this.limit = 1,
    this.types = const <MediaSelectionType>{MediaSelectionType.image, MediaSelectionType.video},
    this.thumbnailWidth = 256,
    this.thumbnailHeight = 256,
  }) : assert(limit >= 1 && limit <= maxLimit, 'limit must be between 1 and $maxLimit'),
       assert(thumbnailWidth > 0, 'thumbnailWidth must be greater than 0'),
       assert(thumbnailHeight > 0, 'thumbnailHeight must be greater than 0');

  /// Construct a new RecentMediaOptions instance.
  ///
  /// Throws if [limit] is not between 1 and [maxLimit], if [types] is empty,
  /// or if [thumbnailWidth] or [thumbnailHeight] is not positive.
  RecentMediaOptions.createAndValidate({
    this.limit = 1,
    this.types = const <MediaSelectionType>{MediaSelectionType.image, MediaSelectionType.video},
    this.thumbnailWidth = 256,
    this.thumbnailHeight = 256,
  }) {
    _validate(
      limit: limit,
      types: types,
      thumbnailWidth: thumbnailWidth,
      thumbnailHeight: thumbnailHeight,
    );
  }

  /// The largest allowed value for [limit].
  static const int maxLimit = 100;

  /// The maximum number of recent media items to return.
  final int limit;

  /// The types of media to include.
  final Set<MediaSelectionType> types;

  /// The target width of each thumbnail, in pixels.
  ///
  /// Thumbnails are scaled to fit within [thumbnailWidth] x [thumbnailHeight]
  /// while preserving the aspect ratio. The platform may return a thumbnail
  /// that is somewhat larger or smaller than requested.
  final int thumbnailWidth;

  /// The target height of each thumbnail, in pixels.
  ///
  /// See [thumbnailWidth].
  final int thumbnailHeight;

  static void _validate({
    required int limit,
    required Set<MediaSelectionType> types,
    required int thumbnailWidth,
    required int thumbnailHeight,
  }) {
    if (limit < 1 || limit > maxLimit) {
      throw ArgumentError.value(limit, 'limit', 'must be between 1 and $maxLimit');
    }
    if (types.isEmpty) {
      throw ArgumentError.value(types, 'types', 'cannot be empty');
    }
    if (thumbnailWidth <= 0) {
      throw ArgumentError.value(thumbnailWidth, 'thumbnailWidth', 'must be greater than 0');
    }
    if (thumbnailHeight <= 0) {
      throw ArgumentError.value(thumbnailHeight, 'thumbnailHeight', 'must be greater than 0');
    }
  }
}
