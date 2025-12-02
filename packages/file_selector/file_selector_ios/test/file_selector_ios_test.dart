// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_ios/file_selector_ios.dart';
import 'package:file_selector_ios/src/messages.g.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeFileSelectorApi api;
  late FileSelectorIOS plugin;

  setUp(() {
    api = FakeFileSelectorApi();
    plugin = FileSelectorIOS(api: api);
  });

  test('registered instance', () {
    FileSelectorIOS.registerWith();
    expect(FileSelectorPlatform.instance, isA<FileSelectorIOS>());
  });

  group('openFile', () {
    setUp(() {
      api.result = <String>['foo'];
    });

    test('passes the accepted type groups correctly', () async {
      const group = XTypeGroup(
        label: 'text',
        extensions: <String>['txt'],
        mimeTypes: <String>['text/plain'],
        uniformTypeIdentifiers: <String>['public.text'],
      );

      const groupTwo = XTypeGroup(
        label: 'image',
        extensions: <String>['jpg'],
        mimeTypes: <String>['image/jpg'],
        uniformTypeIdentifiers: <String>['public.image'],
        webWildCards: <String>['image/*'],
      );

      await plugin.openFile(acceptedTypeGroups: <XTypeGroup>[group, groupTwo]);

      // iOS only accepts uniformTypeIdentifiers.
      expect(
        listEquals(api.passedConfig?.utis, <String>[
          'public.text',
          'public.image',
        ]),
        isTrue,
      );
      expect(api.passedConfig?.allowMultiSelection, isFalse);
    });
    test('throws for a type group that does not support iOS', () async {
      const group = XTypeGroup(
        label: 'images',
        webWildCards: <String>['images/*'],
      );

      await expectLater(
        plugin.openFile(acceptedTypeGroups: <XTypeGroup>[group]),
        throwsArgumentError,
      );
    });

    test('correctly handles no type groups', () async {
      await expectLater(plugin.openFile(), completes);
      expect(
        listEquals(api.passedConfig?.utis, <String>['public.data']),
        isTrue,
      );
    });

    test('correctly handles a wildcard group', () async {
      const group = XTypeGroup(label: 'text');

      await expectLater(
        plugin.openFile(acceptedTypeGroups: <XTypeGroup>[group]),
        completes,
      );
      expect(
        listEquals(api.passedConfig?.utis, <String>['public.data']),
        isTrue,
      );
    });
  });

  group('openFiles', () {
    setUp(() {
      api.result = <String>['foo'];
    });

    test('passes the accepted type groups correctly', () async {
      const group = XTypeGroup(
        label: 'text',
        extensions: <String>['txt'],
        mimeTypes: <String>['text/plain'],
        uniformTypeIdentifiers: <String>['public.text'],
      );

      const groupTwo = XTypeGroup(
        label: 'image',
        extensions: <String>['jpg'],
        mimeTypes: <String>['image/jpg'],
        uniformTypeIdentifiers: <String>['public.image'],
        webWildCards: <String>['image/*'],
      );

      await plugin.openFiles(acceptedTypeGroups: <XTypeGroup>[group, groupTwo]);

      expect(
        listEquals(api.passedConfig?.utis, <String>[
          'public.text',
          'public.image',
        ]),
        isTrue,
      );
      expect(api.passedConfig?.allowMultiSelection, isTrue);
    });

    test('throws for a type group that does not support iOS', () async {
      const group = XTypeGroup(
        label: 'images',
        webWildCards: <String>['images/*'],
      );

      await expectLater(
        plugin.openFiles(acceptedTypeGroups: <XTypeGroup>[group]),
        throwsArgumentError,
      );
    });

    test('correctly handles no type groups', () async {
      await expectLater(plugin.openFiles(), completes);
      expect(
        listEquals(api.passedConfig?.utis, <String>['public.data']),
        isTrue,
      );
    });

    test('correctly handles a wildcard group', () async {
      const group = XTypeGroup(label: 'text');

      await expectLater(
        plugin.openFiles(acceptedTypeGroups: <XTypeGroup>[group]),
        completes,
      );
      expect(
        listEquals(api.passedConfig?.utis, <String>['public.data']),
        isTrue,
      );
    });
  });
}

/// Fake implementation that stores arguments and provides a canned response.
class FakeFileSelectorApi implements FileSelectorApi {
  List<String> result = <String>[];
  FileSelectorConfig? passedConfig;

  @override
  Future<List<String>> openFile(FileSelectorConfig config) async {
    passedConfig = config;
    return result;
  }

  @override
  // ignore: non_constant_identifier_names
  BinaryMessenger? get pigeonVar_binaryMessenger => null;

  @override
  // ignore: non_constant_identifier_names
  String get pigeonVar_messageChannelSuffix => '';
}
