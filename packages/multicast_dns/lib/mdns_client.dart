// ignore_for_file: undefined_named_parameter
// Copyright (c) 2015, the Dartino project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:multicast_dns/src/constants.dart';
import 'package:multicast_dns/src/lookup_resolver.dart';
import 'package:multicast_dns/src/native_protocol_client.dart';
import 'package:multicast_dns/src/packet.dart';
import 'package:multicast_dns/src/resource_record.dart';

export 'package:multicast_dns/src/resource_record.dart';

/// A callback type for [MDnsClient.start] to iterate available network interfaces.
///
/// Impelmentations must ensure they return interfaces appropriate for the [type] parameter.
///
/// See also:
///   * [MDnsClient.allInterfacesFactory]
typedef NetworkInterfacesFactory = Future<Iterable<NetworkInterface>> Function(
    InternetAddressType type);

/// Client for DNS lookup using the mDNS protocol.
///
/// Users should call [MDnsClient.start] when ready to start querying and listening.
/// [MDnsClient.stop] must be called when done to clean up resources.
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
  InternetAddress _mDnsAddress;

  /// Find all network interfaces with an the [InternetAddressType] specified.
  static NetworkInterfacesFactory allInterfacesFactory =
      (InternetAddressType type) => NetworkInterface.list(
            includeLinkLocal: true,
            type: type,
            includeLoopback: true,
          );

  /// Start the mDNS client.
  ///
  /// With no arguments, this method will listen on the IPv4 multicast address
  /// on all IPv4 network interfaces.
  ///
  /// The [listenAddress] parameter must be either [InternetAddress.anyIPv4] or
  /// [InternetAddress.anyIPv6], and will default to anyIPv4.
  ///
  /// The [interfaceFactory] defaults to [allInterfacesFactory].
  Future<void> start({
    InternetAddress listenAddress,
    NetworkInterfacesFactory interfaceFactory,
  }) async {
    listenAddress ??= InternetAddress.anyIPv4;
    interfaceFactory ??= allInterfacesFactory;

    assert(listenAddress.address == InternetAddress.anyIPv4.address ||
        listenAddress.address == InternetAddress.anyIPv6.address);

    if (_started || _starting) {
      return;
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

    _sockets.add(_incoming);

    _mDnsAddress = _incoming.address.type == InternetAddressType.IPv4
        ? mDnsAddressIPv4
        : mDnsAddressIPv6;

    final List<NetworkInterface> interfaces =
        await interfaceFactory(listenAddress.type);

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
      _incoming.joinMulticast(_mDnsAddress, interface);
    }
    _incoming.listen(_handleIncoming);

    _started = true;
    _starting = false;
  }

  /// Stop the client and close any associated sockets.
  void stop() {
    if (!_started) {
      return;
    }
    if (_starting) {
      throw StateError('Cannot stop mDNS client while it is starting.');
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
      throw StateError('mDNS client is not started.');
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
    final List<int> packet = encodeMDnsQuery(name, type: type);
    for (RawDatagramSocket socket in _sockets) {
      socket.send(packet, _mDnsAddress, mDnsPort);
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
