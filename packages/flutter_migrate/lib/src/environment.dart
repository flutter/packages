// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'base/common.dart';
import 'base/logger.dart';

/// Polls the flutter tool for details about the environment and project and exposes it as
/// a mapping of String keys to values.
class FlutterToolsEnvironment {
  FlutterToolsEnvironment({
    required Map<String, Object?> mapping,
  }) : _mapping = mapping;

  static Future<FlutterToolsEnvironment> initializeFlutterToolsEnvironment(
      Logger logger) async {
    final ProcessResult result = await Process.run(
        'flutter', <String>['analyze', '--suggestions', '--machine']);
    if (result.exitCode != 0) {
      if ((result.stderr as String).contains(
          'The "--machine" flag is only valid with the "--version" flag.')) {
        logger.printError(
            'The migrate tool is only compatible with flutter tools 3.4.0 or newer (git hash: 21861423f25ad03c2fdb33854b53f195bc117cb3).');
      }
      throwToolExit(
          'Flutter tool exited while running `flutter analyze --suggestions --machine` with: ${result.stderr}');
    }
    String commandOutput = result.stdout;
    Map<String, Object?> mapping = <String, Object?>{};
    if (commandOutput.contains('{') && commandOutput.endsWith('}\n')) {
      commandOutput = commandOutput.substring(commandOutput.indexOf('{'));
      mapping = jsonDecode(result.stdout);
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

  String? getString(String key) {
    if (_mapping.containsKey(key) &&
        _mapping[key] != null &&
        _mapping[key] is String) {
      return _mapping[key]! as String;
    }
    return null;
  }

  bool? getBool(String key) {
    if (_mapping.containsKey(key) &&
        _mapping[key] != null &&
        _mapping[key] is bool) {
      return _mapping[key]! as bool;
    }
    return null;
  }

  bool containsKey(String key) {
    return _mapping.containsKey(key);
  }
}
