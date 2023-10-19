// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/messages.g.dart',
  objcOptions: ObjcOptions(prefix: 'FPI'),
  objcHeaderOut: 'ios/Classes/messages.g.h',
  objcSourceOut: 'ios/Classes/messages.g.m',
  copyrightHeader: 'pigeons/copyright.txt',
))

/// A serialization of a platform image's data.
class PlatformImageData {
  PlatformImageData(this.data, this.scale);

  /// The image data.
  final Uint8List data;

  /// The image's scale factor.
  final double scale;
}

@HostApi()
abstract class PlatformImagesApi {
  /// Returns the URL for the given resource, or null if no such resource is
  /// found.
  @ObjCSelector('resolveURLForResource:withExtension:')
  String? resolveUrl(String resourceName, String? extension);

  /// Returns the data for the image resource with the given name, or null if
  /// no such resource is found.
  @ObjCSelector('loadImageWithName:')
  PlatformImageData? loadImage(String name);
}
