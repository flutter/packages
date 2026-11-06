// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/services.dart';

import 'retrieve_type.dart';

/// The response object of [ImagePickerPlatform.getLostData].
///
/// Only applies to Android.
/// See also:
/// * [ImagePickerPlatform.getLostData] for more details on retrieving lost data.
@immutable
base class LostDataResponse {
  /// Creates an instance with the given [file], [exception], and [type].
  ///
  /// Any of the params may be null, but this is never considered to be empty.
  const LostDataResponse({this.file, this.exception, this.type, this.files}) : _empty = false;

  /// Initializes an instance with all member params set to null and considered
  /// to be empty.
  const LostDataResponse.empty()
    : file = null,
      exception = null,
      type = null,
      _empty = true,
      files = null;

  /// Whether it is an empty response.
  ///
  /// An empty response should have [file], [exception] and [type] to be null.
  bool get isEmpty => _empty;

  /// The file that was lost in a previous [getImage], [getMultiImage],
  /// [getVideo] or [getMedia] call due to MainActivity being destroyed.
  ///
  /// Can be null if [exception] exists.
  final XFile? file;

  /// The exception of the last [getImage], [getMultiImage] or [getVideo].
  ///
  /// If the last [getImage], [getMultiImage] or [getVideo] threw some exception before the MainActivity destruction,
  /// this variable keeps that exception.
  /// You should handle this exception as if the [getImage], [getMultiImage] or [getVideo] got an exception when
  /// the MainActivity was not destroyed.
  ///
  /// Note that it is not the exception that caused the destruction of the MainActivity.
  final PlatformException? exception;

  /// Can either be [RetrieveType.image], [RetrieveType.video], or [RetrieveType.media].
  ///
  /// If the lost data is empty, this will be null.
  final RetrieveType? type;

  final bool _empty;

  /// The list of files that were lost in a previous [getMultiImage] call due to MainActivity being destroyed.
  ///
  /// When [files] is populated, [file] will refer to the last item in the [files] list.
  ///
  /// Can be null if [exception] exists.
  final List<XFile>? files;
}
