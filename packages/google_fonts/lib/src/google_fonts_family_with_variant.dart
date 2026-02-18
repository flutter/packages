// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'google_fonts_variant.dart';

/// Represents a Google Fonts API variant in Flutter-specific types.
class GoogleFontsFamilyWithVariant {
  /// Creates a representation of a Google Fonts family with a specific variant.
  const GoogleFontsFamilyWithVariant({
    required this.family,
    required this.googleFontsVariant,
  });

  /// The name of the Google Fonts family.
  ///
  /// Example: "Roboto", "Open Sans", etc.
  final String family;

  /// The variant information including weight and style.
  final GoogleFontsVariant googleFontsVariant;

  /// Returns the API filename prefix for this font family and variant.
  ///
  /// Example: "Roboto-400" for regular Roboto.
  String toApiFilenamePrefix() {
    return '$family-${googleFontsVariant.toApiFilenamePart()}';
  }

  /// Returns a font family name that is modified with additional [fontWeight]
  /// and [fontStyle] descriptions.
  ///
  /// This string is used as a key to the loaded or stored fonts that come
  /// from the Google Fonts API.
  @override
  String toString() => '${family}_$googleFontsVariant';
}
