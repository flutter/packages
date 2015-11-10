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
import 'package:mdns/src/constants.dart';

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

    _resolver.clearPendingRequests();

    _started = false;
  }

  Stream<ResourceRecord> lookup(
      int type,
      String name,
      {Duration timeout: const Duration(seconds: 5)}) {
    if (!_started) {
      throw new StateError('mDNS client is not started');
    }

    // Add the pending request before sending the query.
    var result = _resolver.addPendingRequest(type, name, timeout);

    // Send the request.
    //
    //  response[0]: reply port (SendPort)
    //  response[1]: request type (int)
    //  response[2]: record type (int)
    //  response[3]: data (Uint8List)
    //  response[4]: timeout in milliseconds (int)
    _service.send([_incoming.sendPort,
                   RequestType.lookupRequest.index,
                   type,
                   name,
                   timeout.inMilliseconds]);

    return result;
  }

  // Process incoming responses.
  _handleIncoming(response) {
    // Right now the only response we can get is the response to a
    // lookupRequest where the response looks like this:
    //
    //  response[0]: fullname (String)
    //  response[1]: type (int)
    //  response[2]: ttl (int)
    //  response[3]: data (Uint8List)
    if (response is List && response.length == 4) {
      if (response[0] is String &&
          response[1] is int &&
          response[2] is int &&
          response[3] is List) {
        String fqdn = response[0];
        // The strings from the C system can have \032 for spaces.
        fqdn = fqdn.replaceAll(r'\032', ' ');
        int type = response[1];
        int ttl = response[2];
        List<int> data = response[3];

        int validUntil = new DateTime.now().millisecondsSinceEpoch + ttl * 1000;
        ResourceRecord result;
        switch (type) {
          case RRType.A:
            if (data.length == 4) {
              var address =
                  new InternetAddress(data.map((n) => '$n').join('.'));
              result = new ResourceRecord(type, fqdn, address, validUntil);
            }
            break;
          case RRType.SRV:
            // Skip the SRV record header for now - only read the name.
            if (data.length > srvHeaderSize) {
              var rData = readFQDN(data, srvHeaderSize);
              result = new ResourceRecord(type, fqdn, rData, validUntil);
            }
            break;
          case RRType.PTR:
            var rData = readFQDN(data);
            result = new ResourceRecord(type, fqdn, rData, validUntil);
            break;
        }
        if (result != null) {
          _resolver.handleResponse([result]);
        }
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
