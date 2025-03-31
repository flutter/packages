// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:file_selector_platform_interface/src/method_channel/method_channel_file_selector.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$MethodChannelFileSelector()', () {
    final MethodChannelFileSelector plugin = MethodChannelFileSelector();

    final List<MethodCall> log = <MethodCall>[];

    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        plugin.channel,
        (MethodCall methodCall) async {
          log.add(methodCall);
          return null;
        },
      );

      log.clear();
    });

    group('#openFile', () {
      test('passes the accepted type groups correctly', () async {
        const XTypeGroup group = XTypeGroup(
          label: 'text',
          extensions: <String>['txt'],
          mimeTypes: <String>['text/plain'],
          uniformTypeIdentifiers: <String>['public.text'],
        );

        const XTypeGroup groupTwo = XTypeGroup(
            label: 'image',
            extensions: <String>['jpg'],
            mimeTypes: <String>['image/jpg'],
            uniformTypeIdentifiers: <String>['public.image'],
            webWildCards: <String>['image/*']);

        await plugin
            .openFile(acceptedTypeGroups: <XTypeGroup>[group, groupTwo]);

        expectMethodCall(
          log,
          'openFile',
          arguments: <String, dynamic>{
            'acceptedTypeGroups': <Map<String, dynamic>>[
              group.toJSON(),
              groupTwo.toJSON()
            ],
            'initialDirectory': null,
            'confirmButtonText': null,
            'multiple': false,
          },
        );
      });
      test('passes initialDirectory correctly', () async {
        await plugin.openFile(initialDirectory: '/example/directory');

        expectMethodCall(
          log,
          'openFile',
          arguments: <String, dynamic>{
            'acceptedTypeGroups': null,
            'initialDirectory': '/example/directory',
            'confirmButtonText': null,
            'multiple': false,
          },
        );
      });
      test('passes confirmButtonText correctly', () async {
        await plugin.openFile(confirmButtonText: 'Open File');

        expectMethodCall(
          log,
          'openFile',
          arguments: <String, dynamic>{
            'acceptedTypeGroups': null,
            'initialDirectory': null,
            'confirmButtonText': 'Open File',
            'multiple': false,
          },
        );
      });
    });
    group('#openFiles', () {
      test('passes the accepted type groups correctly', () async {
        const XTypeGroup group = XTypeGroup(
          label: 'text',
          extensions: <String>['txt'],
          mimeTypes: <String>['text/plain'],
          uniformTypeIdentifiers: <String>['public.text'],
        );

        const XTypeGroup groupTwo = XTypeGroup(
            label: 'image',
            extensions: <String>['jpg'],
            mimeTypes: <String>['image/jpg'],
            uniformTypeIdentifiers: <String>['public.image'],
            webWildCards: <String>['image/*']);

        await plugin
            .openFiles(acceptedTypeGroups: <XTypeGroup>[group, groupTwo]);

        expectMethodCall(
          log,
          'openFile',
          arguments: <String, dynamic>{
            'acceptedTypeGroups': <Map<String, dynamic>>[
              group.toJSON(),
              groupTwo.toJSON()
            ],
            'initialDirectory': null,
            'confirmButtonText': null,
            'multiple': true,
          },
        );
      });
      test('passes initialDirectory correctly', () async {
        await plugin.openFiles(initialDirectory: '/example/directory');

        expectMethodCall(
          log,
          'openFile',
          arguments: <String, dynamic>{
            'acceptedTypeGroups': null,
            'initialDirectory': '/example/directory',
            'confirmButtonText': null,
            'multiple': true,
          },
        );
      });
      test('passes confirmButtonText correctly', () async {
        await plugin.openFiles(confirmButtonText: 'Open File');

        expectMethodCall(
          log,
          'openFile',
          arguments: <String, dynamic>{
            'acceptedTypeGroups': null,
            'initialDirectory': null,
            'confirmButtonText': 'Open File',
            'multiple': true,
          },
        );
      });
    });

    group('#getSavePath', () {
      test('passes the accepted type groups correctly', () async {
        const XTypeGroup group = XTypeGroup(
          label: 'text',
          extensions: <String>['txt'],
          mimeTypes: <String>['text/plain'],
          uniformTypeIdentifiers: <String>['public.text'],
        );

        const XTypeGroup groupTwo = XTypeGroup(
            label: 'image',
            extensions: <String>['jpg'],
            mimeTypes: <String>['image/jpg'],
            uniformTypeIdentifiers: <String>['public.image'],
            webWildCards: <String>['image/*']);

        await plugin
            .getSavePath(acceptedTypeGroups: <XTypeGroup>[group, groupTwo]);

        expectMethodCall(
          log,
          'getSavePath',
          arguments: <String, dynamic>{
            'acceptedTypeGroups': <Map<String, dynamic>>[
              group.toJSON(),
              groupTwo.toJSON()
            ],
            'initialDirectory': null,
            'suggestedName': null,
            'confirmButtonText': null,
          },
        );
      });
      test('passes initialDirectory correctly', () async {
        await plugin.getSavePath(initialDirectory: '/example/directory');

        expectMethodCall(
          log,
          'getSavePath',
          arguments: <String, dynamic>{
            'acceptedTypeGroups': null,
            'initialDirectory': '/example/directory',
            'suggestedName': null,
            'confirmButtonText': null,
          },
        );
      });
      test('passes confirmButtonText correctly', () async {
        await plugin.getSavePath(confirmButtonText: 'Open File');

        expectMethodCall(
          log,
          'getSavePath',
          arguments: <String, dynamic>{
            'acceptedTypeGroups': null,
            'initialDirectory': null,
            'suggestedName': null,
            'confirmButtonText': 'Open File',
          },
        );
      });
    });
    group('#getDirectoryPath', () {
      test('passes initialDirectory correctly', () async {
        await plugin.getDirectoryPath(initialDirectory: '/example/directory');

        expectMethodCall(
          log,
          'getDirectoryPath',
          arguments: <String, dynamic>{
            'initialDirectory': '/example/directory',
            'confirmButtonText': null,
          },
        );
      });
      test('passes confirmButtonText correctly', () async {
        await plugin.getDirectoryPath(confirmButtonText: 'Select Folder');

        expectMethodCall(
          log,
          'getDirectoryPath',
          arguments: <String, dynamic>{
            'initialDirectory': null,
            'confirmButtonText': 'Select Folder',
          },
        );
      });
    });
    group('#getDirectoryPaths', () {
      test('passes initialDirectory correctly', () async {
        await plugin.getDirectoryPaths(initialDirectory: '/example/directory');

        expectMethodCall(
          log,
          'getDirectoryPaths',
          arguments: <String, dynamic>{
            'initialDirectory': '/example/directory',
            'confirmButtonText': null,
          },
        );
      });
      test('passes confirmButtonText correctly', () async {
        await plugin.getDirectoryPaths(
            confirmButtonText: 'Select one or more Folders');

        expectMethodCall(
          log,
          'getDirectoryPaths',
          arguments: <String, dynamic>{
            'initialDirectory': null,
            'confirmButtonText': 'Select one or more Folders',
          },
        );
      });
    });
  });
}

void expectMethodCall(
  List<MethodCall> log,
  String methodName, {
  Map<String, dynamic>? arguments,
}) {
  expect(log, <Matcher>[isMethodCall(methodName, arguments: arguments)]);
}
