// Copyright (c) 2015, the Fletch project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE.md file.

library mdns.src.native_extension_client;

import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:mdns/mdns.dart';
import 'package:mdns/src/lookup_resolver.dart';
import 'package:mdns/src/native_extension_api.dart'
    deferred as native_extension_api;
import 'package:mdns/src/packet.dart';

// Requests Ids. This should be aligned with the C code.
enum RequestType {
  echoRequest,  // 0
  lookupRequest,  // 1
}

// Implementation of mDNS client using a native extension.
class NativeExtensionMDnsClient implements MDnsClient {
  bool _starting = false;
  bool _started = false;
  SendPort _service;
  ReceivePort _incoming;
  final LookupResolver _resolver = new LookupResolver();

  /// Start the mDNS client.
  Future start() async {
    if (_started && _starting) {
      throw new StateError('mDNS client already started');
    }
    _starting = true;

    await native_extension_api.loadLibrary();
    _service = native_extension_api.servicePort();
    _incoming = new ReceivePort();
    _incoming.listen(_handleIncoming);

    _starting = false;
    _started = true;
  }

  void stop() {
    if (!_started) return;
    if (_starting) {
      throw new StateError('Cannot stop mDNS client wile it is starting');
    }

    _incoming.close();

    _started = false;
  }

  Future<InternetAddress> lookup(
      String hostname, {Duration timeout: const Duration(seconds: 5)}) {
    if (!_started) {
      throw new StateError('mDNS client is not started');
    }

    // Add the pending request before sending the query.
    var future = _resolver.addPendingRequest(hostname, timeout);

    // Send the request.
    _service.send([_incoming.sendPort,
                   RequestType.lookupRequest.index,
                   hostname]);

    return future;
  }

  // Process incoming responses.
  _handleIncoming(response) {
    // Right not the only response we can get is the response to a
    // lookupRequest where the response looks like this:
    //
    //  response[0]: hostname (String)
    //  response[1]: IPv4 address (Uint8List)
    if (response is List && response.length == 2) {
      if (response[0] is String &&
          response[1] is List && response[1].length == 4) {
        response = new DecodeResult(response[0],
                                    new InternetAddress(response[1].join('.')));
        _resolver.handleResponse([response]);
      } else {
        // TODO(sgjesse): Improve the error handling.
        print('mDNS Response not understood');
      }
    }
  }
}

Future nativeExtensionEchoTest(dynamic message) async {
  await native_extension_api.loadLibrary();
  SendPort service = native_extension_api.servicePort();
  ReceivePort port = new ReceivePort();
  try {
    service.send([port.sendPort, RequestType.echoRequest.index, message]);
    return await port.first;
  } finally {
    port.close();
  }
}
