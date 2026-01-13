// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter_platform_interface/src/webview_flutter_platform_interface_legacy.dart';

void main() {
  final log = <String, String>{};
  final channels = <JavascriptChannel>{
    JavascriptChannel(
      name: 'js_channel_1',
      onMessageReceived: (JavascriptMessage message) =>
          log['js_channel_1'] = message.message,
    ),
    JavascriptChannel(
      name: 'js_channel_2',
      onMessageReceived: (JavascriptMessage message) =>
          log['js_channel_2'] = message.message,
    ),
    JavascriptChannel(
      name: 'js_channel_3',
      onMessageReceived: (JavascriptMessage message) =>
          log['js_channel_3'] = message.message,
    ),
  };

  tearDown(() {
    log.clear();
  });

  test('ctor should initialize with channels.', () {
    final registry = JavascriptChannelRegistry(channels);

    expect(registry.channels.length, 3);
    for (final channel in channels) {
      expect(registry.channels[channel.name], channel);
    }
  });

  test(
    'onJavascriptChannelMessage should forward message on correct channel.',
    () {
      final registry = JavascriptChannelRegistry(channels);

      registry.onJavascriptChannelMessage(
        'js_channel_2',
        'test message on channel 2',
      );

      expect(log, containsPair('js_channel_2', 'test message on channel 2'));
    },
  );

  test(
    'onJavascriptChannelMessage should throw ArgumentError when message arrives on non-existing channel.',
    () {
      final registry = JavascriptChannelRegistry(channels);

      expect(
        () => registry.onJavascriptChannelMessage(
          'js_channel_4',
          'test message on channel 2',
        ),
        throwsA(
          isA<ArgumentError>().having(
            (ArgumentError error) => error.message,
            'message',
            'No channel registered with name js_channel_4.',
          ),
        ),
      );
    },
  );

  test(
    'updateJavascriptChannelsFromSet should clear all channels when null is supplied.',
    () {
      final registry = JavascriptChannelRegistry(channels);

      expect(registry.channels.length, 3);

      registry.updateJavascriptChannelsFromSet(null);

      expect(registry.channels, isEmpty);
    },
  );

  test(
    'updateJavascriptChannelsFromSet should update registry with new set.',
    () {
      final registry = JavascriptChannelRegistry(channels);

      expect(registry.channels.length, 3);

      final newChannels = <JavascriptChannel>{
        JavascriptChannel(
          name: 'new_js_channel_1',
          onMessageReceived: (JavascriptMessage message) =>
              log['new_js_channel_1'] = message.message,
        ),
        JavascriptChannel(
          name: 'new_js_channel_2',
          onMessageReceived: (JavascriptMessage message) =>
              log['new_js_channel_2'] = message.message,
        ),
      };

      registry.updateJavascriptChannelsFromSet(newChannels);

      expect(registry.channels.length, 2);
      for (final channel in newChannels) {
        expect(registry.channels[channel.name], channel);
      }
    },
  );
}
