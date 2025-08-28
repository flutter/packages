// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// TODO(stuartmorgan): Remove, and fix violations.
// ignore_for_file: public_member_api_docs

import 'google_fonts_variant.dart';

/// Represents a Google Fonts API variant in Flutter-specific types.
class GoogleFontsFamilyWithVariant {
  const GoogleFontsFamilyWithVariant({
    required this.family,
    required this.googleFontsVariant,
  });

  final String family;
  final GoogleFontsVariant googleFontsVariant;

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
