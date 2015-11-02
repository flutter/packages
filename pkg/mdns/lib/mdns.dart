// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:mdns/src/constants.dart';
import 'package:mdns/src/lookup_resolver.dart';
import 'package:mdns/src/packet.dart';

/// Client for DNS lookup using the mDNS protocol.
///
/// This client only support "One-Shot Multicast DNS Queries" as described in
/// section 5.1 of https://tools.ietf.org/html/rfc6762
class MDnsClient {
  bool _starting = false;
  bool _started = false;
  RawDatagramSocket _incoming;
  final List<RawDatagramSocket> _sockets = <RawDatagramSocket>[];
  final LookupResolver _resolver = new LookupResolver();

  /// Start the mDNS client.
  Future start() async {
    if (_started && _starting) {
      throw new StateError('mDNS client already started');
    }
    _starting = true;

    // Listen on all addresses.
    _incoming = await RawDatagramSocket.bind(
        InternetAddress.ANY_IP_V4, mDnsPort, reuseAddress: true);

    // Find all network interfaces with an IPv4 address.
    var interfaces =
        await NetworkInterface.list(type: InternetAddressType.IP_V4);
    for (NetworkInterface interface in interfaces) {
      // Create a socket for sending on each adapter.
      var socket = await RawDatagramSocket.bind(
          interface.addresses[0], mDnsPort, reuseAddress: true);
      _sockets.add(socket);

      // Join multicast on this interface.
      _incoming.joinMulticast(mDnsAddress, interface);
    }
    _incoming.listen(_handleIncoming);

    _starting = false;
    _started = true;
  }

  /// Stop the mDNS client.
  void stop() {
    if (!_started) return;
    if (_starting) {
      throw new StateError('Cannot stop mDNS client wile it is starting');
    }

    _sockets.forEach((socket) => socket.close());
    _incoming.close();

    _started = false;
  }

  /// Lookup [hostname] using mDNS.
  ///
  /// The `hostname` must have the form `single-dns-label.local`,
  /// e.g. `printer.local`.
  ///
  /// If no answer has been received within the specified [timeout]
  /// this method will complete with the value `null`.
  Future<InternetAddress> lookup(
      String hostname, {Duration timeout: const Duration(seconds: 5)}) {
    if (!_started) {
      throw new StateError('mDNS client is not started');
    }

    // Add the pending request before sending the query.
    var future = _resolver.addPendingRequest(hostname, timeout);

    // Send the request on all interfaces.
    List<int> packet = encodeMDnsQuery(hostname);
    for (int i = 0; i < _sockets.length; i++) {
      _sockets[i].send(packet, mDnsAddress, mDnsPort);
    }

    return future;
  }

  // Process incoming datagrams.
  _handleIncoming(event) {
    if (event == RawSocketEvent.READ) {
      var data = _incoming.receive();
      var response = decodeMDnsResponse(data.data);
      if (response != null) {
        _resolver.handleResponse(response);
      }
    }
  }
}

// Simple standalone test.
main() async {
  var client = new MDnsClient();
  await client.start();
  var address = await client.lookup('raspberrypi.local');
  client.stop();
  print(address);
}
