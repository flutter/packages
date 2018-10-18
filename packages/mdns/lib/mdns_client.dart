// ignore_for_file: undefined_named_parameter
// Copyright (c) 2015, the Dartino project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE.md file.

import 'dart:async';
import 'dart:io';

import 'package:dart_mdns/src/constants.dart';
import 'package:dart_mdns/src/lookup_resolver.dart';
import 'package:dart_mdns/src/native_protocol_client.dart';
import 'package:dart_mdns/src/packet.dart';

export 'package:dart_mdns/src/constants.dart' show RRType;
export 'package:dart_mdns/src/packet.dart'
    show
        ResourceRecord,
        IPAddressResourceRecord,
        SrvResourceRecord,
        TxtResourceRecord,
        PtrResourceRecord;

/// Client for DNS lookup using the mDNS protocol.
///
/// This client only support "One-Shot Multicast DNS Queries" as described in
/// section 5.1 of https://tools.ietf.org/html/rfc6762
class MDnsClient {
  bool _starting = false;
  bool _started = false;
  RawDatagramSocket _incoming;
  final List<RawDatagramSocket> _sockets = <RawDatagramSocket>[];
  final LookupResolver _resolver = LookupResolver();
  final ResourceRecordCache _cache = ResourceRecordCache();

  /// Start the mDNS client.
  Future<void> start() async {
    if (_started && _starting) {
      throw StateError('mDNS client already started');
    }
    _starting = true;

    // Listen on all addresses.
    _incoming = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      mDnsPort,
      reuseAddress: true,
      reusePort: true,
      ttl: 255,
    );
    // Find all network interfaces with an IPv4 address.
    final List<NetworkInterface> interfaces = await NetworkInterface.list(
      includeLinkLocal: true,
      type: InternetAddressType.IPv4,
      includeLoopback: true,
    );

    _sockets.add(_incoming);

    for (NetworkInterface interface in interfaces) {
      // Create a socket for sending on each adapter.
      final RawDatagramSocket socket = await RawDatagramSocket.bind(
        interface.addresses[0],
        mDnsPort,
        reuseAddress: true,
        reusePort: true,
        ttl: 255,
      );
      _sockets.add(socket);

      // Join multicast on this interface.
      _incoming.joinMulticast(mDnsAddress, interface);
    }
    _incoming.listen(_handleIncoming);

    _starting = false;
    _started = true;
  }

  /// Stop the client and close any associated sockets.
  void stop() {
    if (!_started) {
      return;
    }
    if (_starting) {
      throw StateError('Cannot stop mDNS client wile it is starting');
    }

    for (RawDatagramSocket socket in _sockets) {
      socket.close();
    }

    _resolver.clearPendingRequests();

    _started = false;
  }

  /// Lookup a [ResourceRecord], potentially from cache.
  Stream<ResourceRecord> lookup(int type, String name,
      {Duration timeout = const Duration(seconds: 5)}) {
    if (!_started) {
      throw StateError('mDNS client is not started');
    }
    // Look for entries in the cache.
    final List<ResourceRecord> cached = <ResourceRecord>[];
    _cache.lookup(name, type, cached);
    if (cached.isNotEmpty) {
      final StreamController<ResourceRecord> controller =
          StreamController<ResourceRecord>();
      cached.forEach(controller.add);
      controller.close();
      return controller.stream;
    }

    // Add the pending request before sending the query.
    final Stream<ResourceRecord> results =
        _resolver.addPendingRequest(type, name, timeout);

    // Send the request on all interfaces.
    final List<int> packet = encodeMDnsQuery(name, type);
    for (RawDatagramSocket socket in _sockets) {
      socket.send(packet, mDnsAddress, mDnsPort);
    }
    return results;
  }

  // Process incoming datagrams.
  void _handleIncoming(RawSocketEvent event) {
    if (event == RawSocketEvent.read) {
      final Datagram datagram = _incoming.receive();

      final List<ResourceRecord> response = decodeMDnsResponse(datagram.data);
      if (response != null) {
        _cache.updateRecords(response);
        _resolver.handleResponse(response);
      }
    }
  }
}
