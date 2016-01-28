// Copyright (c) 2015, the Dartino project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE.md file.

library mdns.src.native_protocol_client;

import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:mdns/mdns.dart';
import 'package:mdns/src/constants.dart';
import 'package:mdns/src/lookup_resolver.dart';
import 'package:mdns/src/packet.dart';

/// Cache for resource records that have been received.
///
/// There can be multiple entries for the same name and type.
///
/// The cached is updated with a list of records, because it needs to remove
/// all entries that correspond to name and type of the name/type combinations
/// of records that should be updated.  For example, a host may remove one
/// of its IP addresses and report the remaining address as a response - then
/// we need to clear all previous entries for that host before updating the
/// cache.
class ResourceRecordCache {
  final List buffer;
  final int size;
  int position;

  ResourceRecordCache({int size: 32})
    : buffer = new List(size),
      size = size,
      position = 0;

  void updateRecords(List<ResourceRecord> records) {
    // TODO(karlklose): include flush bit in the record and only flush if
    // necessary.
    // Clear the cache for all name/type combinations to be updated.
    for (int i = 0; i < size; i++) {
      ResourceRecord r = buffer[i % size];
      if (r == null) continue;
      String name = r.name;
      int type = r.type;
      for (ResourceRecord record in records) {
        if (name == record.name && type == record.type) {
          buffer[i % size] = null;
          break;
        }
      }
    }
    // Add the new records.
    for (ResourceRecord record in records) {
      buffer[position] = record;
      position = (position + 1) % size;
    }
  }

  void lookup(String name, int type, List results) {
    int time = new DateTime.now().millisecondsSinceEpoch;
    for (int i = position + size; i >= position; i--) {
      int index = i % size;
      ResourceRecord record = buffer[index];
      if (record == null) continue;
      if (record.validUntil < time) {
        buffer[index] = null;
      } else if (record.name == name && record.type == type) {
        results.add(record);
      }
    }
  }
}

// Implementation of mDNS client using the native protocol.
class NativeProtocolMDnsClient implements MDnsClient {
  bool _starting = false;
  bool _started = false;
  RawDatagramSocket _incoming;
  final List<RawDatagramSocket> _sockets = <RawDatagramSocket>[];
  final LookupResolver _resolver = new LookupResolver();
  ResourceRecordCache cache = new ResourceRecordCache();

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
      (_incoming as dynamic).joinMulticast(mDnsAddress, interface);
    }
    _incoming.listen(_handleIncoming);

    _starting = false;
    _started = true;
  }

  void stop() {
    if (!_started) return;
    if (_starting) {
      throw new StateError('Cannot stop mDNS client wile it is starting');
    }

    _sockets.forEach((socket) => socket.close());
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

    // Look for entries in the cache.
    List<ResourceRecord> cached = <ResourceRecord>[];
    cache.lookup(name, type, cached);
    if (cached.isNotEmpty) {
      StreamController controller = new StreamController();
      cached.forEach(controller.add);
      controller.close();
      return controller.stream;
    }

    // Add the pending request before sending the query.
    var results = _resolver.addPendingRequest(type, name, timeout);

    // Send the request on all interfaces.
    List<int> packet = encodeMDnsQuery(name, type);
    for (int i = 0; i < _sockets.length; i++) {
      _sockets[i].send(packet, mDnsAddress, mDnsPort);
    }

    return results;
  }

  // Process incoming datagrams.
  _handleIncoming(event) {
    if (event == RawSocketEvent.READ) {
      Datagram datagram = _incoming.receive();
      List<ResourceRecord> response = decodeMDnsResponse(datagram.data);
      if (response != null) {
        cache.updateRecords(response);
        _resolver.handleResponse(response);
      }
    }
  }
}
