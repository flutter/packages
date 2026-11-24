// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'localizations_utils.dart';

/// Returns the header of the generated Material localizations file: the
/// license, the regeneration instructions, and the imports.
String generateMaterialHeader(String regenerateInstructions) {
  return '''
// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file has been automatically generated. Please do not edit it manually.
// To regenerate the file, use:
// $regenerateInstructions

import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' as intl;

import '../global_material_localizations.dart';
import '../time.dart';
import '../typography.dart';

// The classes defined here encode all of the translations found in the
// `material_ui/lib/src/l10n/*.arb` files.
//
// These classes are constructed by the [getMaterialTranslation] method at the
// bottom of this file, and used by the [_MaterialLocalizationsDelegate.load]
// method defined in `packages/material_ui/lib/src/global_material_localizations.dart`.

// TODO(goderbauer): Extend the generator to properly format the output.
// dart format off''';
}

/// Returns the source of the constructor for a GlobalMaterialLocalizations
/// subclass.
String generateMaterialConstructor(LocaleInfo locale) {
  final String localeName = locale.originalString;
  return '''
  /// Create an instance of the translation bundle for ${describeLocale(localeName)}.
  ///
  /// For details on the meaning of the arguments, see [GlobalMaterialLocalizations].
  const MaterialLocalization${locale.camelCase()}({
    super.localeName = '$localeName',
    required super.fullYearFormat,
    required super.compactDateFormat,
    required super.shortDateFormat,
    required super.mediumDateFormat,
    required super.longDateFormat,
    required super.yearMonthFormat,
    required super.shortMonthDayFormat,
    required super.decimalFormat,
    required super.twoDigitZeroPaddedFormat,
  });''';
}

/// The name of the generated function that returns the translations for a
/// given locale.
const String materialFactoryName = 'getMaterialTranslation';

/// The declaration of the generated [materialFactoryName] function.
const String materialFactoryDeclaration = '''
GlobalMaterialLocalizations? getMaterialTranslation(
  Locale locale,
  intl.DateFormat fullYearFormat,
  intl.DateFormat compactDateFormat,
  intl.DateFormat shortDateFormat,
  intl.DateFormat mediumDateFormat,
  intl.DateFormat longDateFormat,
  intl.DateFormat yearMonthFormat,
  intl.DateFormat shortMonthDayFormat,
  intl.NumberFormat decimalFormat,
  intl.NumberFormat twoDigitZeroPaddedFormat,
) {''';

/// The arguments that the generated [materialFactoryName] function passes to
/// the constructor of each generated localization class.
const String materialFactoryArguments =
    'fullYearFormat: fullYearFormat, compactDateFormat: compactDateFormat, shortDateFormat: shortDateFormat, mediumDateFormat: mediumDateFormat, longDateFormat: longDateFormat, yearMonthFormat: yearMonthFormat, shortMonthDayFormat: shortMonthDayFormat, decimalFormat: decimalFormat, twoDigitZeroPaddedFormat: twoDigitZeroPaddedFormat';

/// The name of the generated constant that lists the supported language codes.
const String materialSupportedLanguagesConstant = 'kMaterialSupportedLanguages';

/// The name of the dartdoc template that documents the supported languages.
const String materialSupportedLanguagesDocMacro = 'material_ui.localizations.languages';
