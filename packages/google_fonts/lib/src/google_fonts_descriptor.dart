// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'google_fonts_family_with_variant.dart';

/// Describes a Google Fonts API font.
///
/// This class mostly serves as a simple way to keep the connected font
/// information together.
class GoogleFontsDescriptor {
  /// Creates a descriptor for a Google Fonts font.
  ///
  /// The [familyWithVariant] describes the font family and variant, while
  /// the [file] contains information about the font file such as its hash and
  /// expected length.
  const GoogleFontsDescriptor({
    required this.familyWithVariant,
    required this.file,
  });

  /// The font family and variant information.
  ///
  /// Example: "Roboto" with a variant with weight "400" and style "regular".
  final GoogleFontsFamilyWithVariant familyWithVariant;

  /// The font file information including hash and expected length.
  final GoogleFontsFile file;
}

/// Describes a font file as it is _expected_ to be received from the server.
///
/// If a file is retrieved and its hash does not match [expectedFileHash], or it
/// is not of [expectedLength] bytes length, the font will not be loaded, and
/// the file will not be stored on the device.
class GoogleFontsFile {
  /// Creates a font file descriptor with expected hash and length validation.
  ///
  /// The [expectedFileHash] is used to verify the integrity of the downloaded
  /// file, and [expectedLength] is checked to ensure the file size is correct.
  GoogleFontsFile(this.expectedFileHash, this.expectedLength);

  /// The expected hash of the font file for validation.
  final String expectedFileHash;

  /// The expected length in bytes of the font file.
  final int expectedLength;

  /// The URL from which the font file can be downloaded.
  String get url => 'https://fonts.gstatic.com/s/a/$expectedFileHash.ttf';
}
