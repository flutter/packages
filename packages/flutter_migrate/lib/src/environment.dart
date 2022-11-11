// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:process/process.dart';

import 'base/common.dart';
import 'base/logger.dart';

/// Polls the flutter tool for details about the environment and project and exposes it as
/// a mapping of String keys to values.
///
/// This class is based on the `flutter analyze --suggestions --machine` flutter_tools command
/// which dumps various variables as JSON.
class FlutterToolsEnvironment {
  /// Constructs a tools environment out of a mapping of Strings to Object values.
  ///
  /// Each key is the String URI-style description of a value in the Flutter tool
  /// and is mapped to a String or boolean value. The mapping should align with the
  /// JSON output of `flutter analyze --suggestions --machine`.
  FlutterToolsEnvironment({
    required Map<String, Object?> mapping,
  }) : _mapping = mapping;

  /// Creates a FlutterToolsEnvironment instance by calling `flutter analyze --suggestions --machine`
  /// and parsing its output.
  static Future<FlutterToolsEnvironment> initializeFlutterToolsEnvironment(
      ProcessManager processManager, Logger logger) async {
    final ProcessResult result = await processManager
        .run(<String>['flutter', 'analyze', '--suggestions', '--machine']);
    if (result.exitCode != 0) {
      if ((result.stderr as String).contains(
          'The "--machine" flag is only valid with the "--version" flag.')) {
        logger.printError(
            'The migrate tool is only compatible with flutter tools 3.4.0 or newer (git hash: 21861423f25ad03c2fdb33854b53f195bc117cb3).');
      }
      throwToolExit(
          'Flutter tool exited while running `flutter analyze --suggestions --machine` with: ${result.stderr}');
    }
    String commandOutput = (result.stdout as String).trim();
    Map<String, Object?> mapping = <String, Object?>{};
    // minimally validate basic JSON format and trim away any accidental logging before.
    if (commandOutput.contains(RegExp(r'[\s\S]*{[\s\S]+}[\s\S]*'))) {
      commandOutput = commandOutput.substring(commandOutput.indexOf('{'));
      mapping = jsonDecode(commandOutput.replaceAll(r'\', r'\\'));
    }
    return FlutterToolsEnvironment(mapping: mapping);
  }

  final Map<String, Object?> _mapping;

  Object? operator [](String key) {
    if (_mapping.containsKey(key)) {
      return _mapping[key];
    }
    return null;
  }

  /// Returns the String stored at the key and null if
  /// the key does not exist or is not a String.
  String? getString(String key) {
    final Object? value = _mapping[key];
    return value is String? ? value : null;
  }

  /// Returns the bool stored at the key and null if
  /// the key does not exist or is not a bool.
  bool? getBool(String key) {
    final Object? value = _mapping[key];
    return value is bool? ? value : null;
  }

  bool containsKey(String key) {
    return _mapping.containsKey(key);
  }
}
