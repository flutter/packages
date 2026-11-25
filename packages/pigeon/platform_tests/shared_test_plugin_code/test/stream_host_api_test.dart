// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_test_plugin_code/src/generated/event_channel_tests.gen.dart';

class _FakeBinaryMessenger implements BinaryMessenger {
  final Map<String, MessageHandler> incomingHandlers = <String, MessageHandler>{};
  final Map<String, Future<ByteData?> Function(ByteData? message)> outgoingHandlers =
      <String, Future<ByteData?> Function(ByteData? message)>{};

  @override
  void setMessageHandler(String channel, MessageHandler? handler) {
    if (handler == null) {
      incomingHandlers.remove(channel);
    } else {
      incomingHandlers[channel] = handler;
    }
  }

  @override
  Future<ByteData?>? send(String channel, ByteData? message) {
    final Future<ByteData?> Function(ByteData? message)? handler = outgoingHandlers[channel];
    if (handler == null) {
      return Future<ByteData?>.value();
    }
    return handler(message);
  }

  Future<void> emitToDart(String channel, ByteData? message) async {
    final MessageHandler? handler = incomingHandlers[channel];
    if (handler != null) {
      await handler(message);
    }
  }

  @override
  Future<void> handlePlatformMessage(
    String channel,
    ByteData? data,
    PlatformMessageResponseCallback? callback,
  ) async {}
}

void main() {
  const controlChannel =
      'dev.flutter.pigeon.pigeon_integration_tests.StreamHostTestApi.streamNumbers';
  const eventsChannel = '$controlChannel.events';
  const MessageCodec<Object?> codec = StreamHostTestApi.pigeonChannelCodec;

  test('multiplexes concurrent subscriptions and cleans up events handler on completion', () async {
    final messenger = _FakeBinaryMessenger();
    final receivedRequests = <List<Object?>>[];
    messenger.outgoingHandlers[controlChannel] = (ByteData? raw) async {
      final request = codec.decodeMessage(raw)! as List<Object?>;
      receivedRequests.add(request);
      final action = request[0]! as String;
      if (action == 'listen') {
        final subId = request[1]! as int;
        final count = request[2]! as int;
        final start = request[3]! as int;
        unawaited(
          Future<void>.microtask(() async {
            for (var i = 0; i < count; i++) {
              await messenger.emitToDart(
                eventsChannel,
                codec.encodeMessage(<Object?>[subId, 0, start + i]),
              );
            }
            await messenger.emitToDart(eventsChannel, codec.encodeMessage(<Object?>[subId, 2]));
          }),
        );
      }
      return codec.encodeMessage(<Object?>[null]);
    };

    final api = StreamHostTestApi(binaryMessenger: messenger);
    final Future<List<int>> first = api.streamNumbers(count: 3, start: 10).toList();
    final Future<List<int>> second = api.streamNumbers(count: 2, start: 100).toList();

    expect(messenger.incomingHandlers, contains(eventsChannel));
    expect(await first, <int>[10, 11, 12]);
    expect(await second, <int>[100, 101]);

    // Natural completion must not bounce redundant 'cancel' calls and must detach the handler.
    expect(receivedRequests.where((List<Object?> r) => r[0] == 'cancel'), isEmpty);
    expect(messenger.incomingHandlers, isNot(contains(eventsChannel)));
  });

  test('sends cancel on mid-stream cancellation and omits cancel on terminal host error', () async {
    final messenger = _FakeBinaryMessenger();
    final cancelledIds = <int>[];
    late int activeSubId;
    messenger.outgoingHandlers[controlChannel] = (ByteData? raw) async {
      final request = codec.decodeMessage(raw)! as List<Object?>;
      if (request[0] == 'listen') {
        activeSubId = request[1]! as int;
        await messenger.emitToDart(
          eventsChannel,
          codec.encodeMessage(<Object?>[activeSubId, 0, 42]),
        );
      } else if (request[0] == 'cancel') {
        cancelledIds.add(request[1]! as int);
      }
      return codec.encodeMessage(<Object?>[null]);
    };

    final api = StreamHostTestApi(binaryMessenger: messenger);
    final List<int> taken = await api.streamNumbers(count: 10, start: 42).take(1).toList();
    expect(taken, <int>[42]);
    expect(cancelledIds, <int>[activeSubId]);
    expect(messenger.incomingHandlers, isNot(contains(eventsChannel)));

    // Now test terminal error frame: no cancel call should be emitted.
    cancelledIds.clear();
    const errorControl =
        'dev.flutter.pigeon.pigeon_integration_tests.StreamHostTestApi.streamError';
    const errorEvents = '$errorControl.events';
    messenger.outgoingHandlers[errorControl] = (ByteData? raw) async {
      final request = codec.decodeMessage(raw)! as List<Object?>;
      if (request[0] == 'listen') {
        final subId = request[1]! as int;
        unawaited(
          Future<void>.microtask(() async {
            await messenger.emitToDart(
              errorEvents,
              codec.encodeMessage(<Object?>[subId, 1, 'bad', 'msg', 'det']),
            );
          }),
        );
      } else if (request[0] == 'cancel') {
        cancelledIds.add(request[1]! as int);
      }
      return codec.encodeMessage(<Object?>[null]);
    };

    await expectLater(
      api.streamError(true).toList(),
      throwsA(
        isA<PlatformException>()
            .having((PlatformException e) => e.code, 'code', 'bad')
            .having((PlatformException e) => e.message, 'message', 'msg')
            .having((PlatformException e) => e.details, 'details', 'det'),
      ),
    );
    expect(cancelledIds, isEmpty);
    expect(messenger.incomingHandlers, isNot(contains(errorEvents)));
  });

  test('cancelling one of two concurrent subscriptions keeps the other active', () async {
    final messenger = _FakeBinaryMessenger();
    final subIds = <int>[];
    final cancelledIds = <int>[];
    messenger.outgoingHandlers[controlChannel] = (ByteData? raw) async {
      final request = codec.decodeMessage(raw)! as List<Object?>;
      if (request[0] == 'listen') {
        subIds.add(request[1]! as int);
      } else if (request[0] == 'cancel') {
        cancelledIds.add(request[1]! as int);
      }
      return codec.encodeMessage(<Object?>[null]);
    };

    final api = StreamHostTestApi(binaryMessenger: messenger);
    final firstEvents = <int>[];
    final secondEvents = <int>[];
    final secondDone = Completer<void>();

    final StreamSubscription<int> sub1 = api.streamNumbers(start: 1).listen(firstEvents.add);
    final StreamSubscription<int> sub2 = api
        .streamNumbers(start: 100)
        .listen(secondEvents.add, onDone: secondDone.complete);

    await Future<void>.microtask(() {});
    expect(subIds.length, 2);
    expect(messenger.incomingHandlers, contains(eventsChannel));

    // Cancel the first subscription; the shared .events handler must stay attached for sub2.
    await sub1.cancel();
    expect(cancelledIds, <int>[subIds[0]]);
    expect(messenger.incomingHandlers, contains(eventsChannel));

    await messenger.emitToDart(eventsChannel, codec.encodeMessage(<Object?>[subIds[1], 0, 100]));
    await messenger.emitToDart(eventsChannel, codec.encodeMessage(<Object?>[subIds[1], 2]));
    await secondDone.future;

    expect(firstEvents, isEmpty);
    expect(secondEvents, <int>[100]);
    expect(messenger.incomingHandlers, isNot(contains(eventsChannel)));
    await sub2.cancel();
  });

  test('propagates listen failure (channel-error and host error) and detaches handler', () async {
    // 1. Unregistered host channel returns null -> channel-error PlatformException.
    final unregisteredMessenger = _FakeBinaryMessenger();
    final unregisteredApi = StreamHostTestApi(binaryMessenger: unregisteredMessenger);
    await expectLater(
      unregisteredApi.streamNumbers(count: 1).toList(),
      throwsA(
        isA<PlatformException>().having((PlatformException e) => e.code, 'code', 'channel-error'),
      ),
    );
    expect(unregisteredMessenger.incomingHandlers, isNot(contains(eventsChannel)));

    // 2. Host error reply on listen -> PlatformException and no cancel message sent.
    final errorMessenger = _FakeBinaryMessenger();
    final actions = <String>[];
    errorMessenger.outgoingHandlers[controlChannel] = (ByteData? raw) async {
      final request = codec.decodeMessage(raw)! as List<Object?>;
      actions.add(request[0]! as String);
      return codec.encodeMessage(<Object?>['listen-failed', 'denied', null]);
    };
    final errorApi = StreamHostTestApi(binaryMessenger: errorMessenger);
    await expectLater(
      errorApi.streamNumbers(count: 1).toList(),
      throwsA(
        isA<PlatformException>()
            .having((PlatformException e) => e.code, 'code', 'listen-failed')
            .having((PlatformException e) => e.message, 'message', 'denied'),
      ),
    );
    expect(actions, <String>['listen']);
    expect(errorMessenger.incomingHandlers, isNot(contains(eventsChannel)));
  });

  test('propagates cancel error reply and decodeEvent cast errors', () async {
    final messenger = _FakeBinaryMessenger();
    late int activeSubId;
    messenger.outgoingHandlers[controlChannel] = (ByteData? raw) async {
      final request = codec.decodeMessage(raw)! as List<Object?>;
      if (request[0] == 'listen') {
        activeSubId = request[1]! as int;
        return codec.encodeMessage(<Object?>[null]);
      }
      return codec.encodeMessage(<Object?>['cancel-failed', 'close error', 'info']);
    };

    final api = StreamHostTestApi(binaryMessenger: messenger);
    final errors = <Object>[];
    final StreamSubscription<int> sub = api.streamNumbers().listen((_) {}, onError: errors.add);

    await Future<void>.microtask(() {});
    // Emit a wrong-typed event (String instead of int) to exercise decodeEvent error routing.
    await messenger.emitToDart(
      eventsChannel,
      codec.encodeMessage(<Object?>[activeSubId, 0, 'not-an-int']),
    );
    expect(errors, hasLength(1));
    expect(errors.single, isA<TypeError>());

    // Cancelling propagates the host's error reply from 'cancel'.
    await expectLater(
      sub.cancel(),
      throwsA(
        isA<PlatformException>()
            .having((PlatformException e) => e.code, 'code', 'cancel-failed')
            .having((PlatformException e) => e.message, 'message', 'close error')
            .having((PlatformException e) => e.details, 'details', 'info'),
      ),
    );
    expect(messenger.incomingHandlers, isNot(contains(eventsChannel)));
  });

  test('isolates stream routers across distinct BinaryMessenger instances', () async {
    final messengerA = _FakeBinaryMessenger();
    final messengerB = _FakeBinaryMessenger();
    late int subIdA;
    late int subIdB;
    messengerA.outgoingHandlers[controlChannel] = (ByteData? raw) async {
      final request = codec.decodeMessage(raw)! as List<Object?>;
      if (request[0] == 'listen') {
        subIdA = request[1]! as int;
      }
      return codec.encodeMessage(<Object?>[null]);
    };
    messengerB.outgoingHandlers[controlChannel] = (ByteData? raw) async {
      final request = codec.decodeMessage(raw)! as List<Object?>;
      if (request[0] == 'listen') {
        subIdB = request[1]! as int;
      }
      return codec.encodeMessage(<Object?>[null]);
    };

    final apiA = StreamHostTestApi(binaryMessenger: messengerA);
    final apiB = StreamHostTestApi(binaryMessenger: messengerB);
    final eventsA = <int>[];
    final eventsB = <int>[];
    final doneA = Completer<void>();
    final doneB = Completer<void>();

    final StreamSubscription<int> subA = apiA
        .streamNumbers(start: 1)
        .listen(eventsA.add, onDone: doneA.complete);
    final StreamSubscription<int> subB = apiB
        .streamNumbers(start: 100)
        .listen(eventsB.add, onDone: doneB.complete);

    await Future<void>.microtask(() {});
    expect(messengerA.incomingHandlers, contains(eventsChannel));
    expect(messengerB.incomingHandlers, contains(eventsChannel));

    // Completing messengerA's stream must not detach messengerB's router.
    await messengerA.emitToDart(eventsChannel, codec.encodeMessage(<Object?>[subIdA, 0, 1]));
    await messengerA.emitToDart(eventsChannel, codec.encodeMessage(<Object?>[subIdA, 2]));
    await doneA.future;
    expect(eventsA, <int>[1]);
    expect(messengerA.incomingHandlers, isNot(contains(eventsChannel)));
    expect(messengerB.incomingHandlers, contains(eventsChannel));

    await messengerB.emitToDart(eventsChannel, codec.encodeMessage(<Object?>[subIdB, 0, 100]));
    await messengerB.emitToDart(eventsChannel, codec.encodeMessage(<Object?>[subIdB, 2]));
    await doneB.future;
    expect(eventsB, <int>[100]);
    expect(messengerB.incomingHandlers, isNot(contains(eventsChannel)));
    await subA.cancel();
    await subB.cancel();
  });
}
