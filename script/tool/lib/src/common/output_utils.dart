// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:colorize/colorize.dart';
import 'package:meta/meta.dart';

export 'package:colorize/colorize.dart' show Styles;

/// True if color should be applied.
///
/// Defaults to autodetecting stdout.
@visibleForTesting
bool useColorForOutput = stdout.supportsAnsiEscapes;

String _colorizeIfAppropriate(String string, Styles color) {
  if (!useColorForOutput) {
    return string;
  }
  return Colorize(string).apply(color).toString();
}

/// Prints [message] in green, if the environment supports color.
void printSuccess(String message) {
  print(_colorizeIfAppropriate(message, Styles.GREEN));
}

/// Prints [message] in yellow, if the environment supports color.
void printWarning(String message) {
  print(_colorizeIfAppropriate(message, Styles.YELLOW));
}

/// Prints [message] in red, if the environment supports color.
void printError(String message) {
  print(_colorizeIfAppropriate(message, Styles.RED));
}

/// Prints [message] in dark grey, if the environment supports color.
void printSkip(String message) {
  print(_colorizeIfAppropriate(message, Styles.DARK_GRAY));
}

/// Returns [message] with escapes to print it in [color], if the environment
/// supports color.
String colorizeString(String message, Styles color) {
  return _colorizeIfAppropriate(message, color);
}
