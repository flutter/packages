// Copyright (c) 2015, the Dartino project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:collection';

import 'package:multicast_dns/src/resource_record.dart';

/// Class for maintaining state about pending mDNS requests.
class PendingRequest extends LinkedListEntry<PendingRequest> {
  /// Creates a new PendingRequest.
  PendingRequest(this.type, this.name, this.controller);

  /// The [RRType] of the request.
  final int type;

  /// The domain name.
  final String name;

  /// A StreamController managing the request.
  final StreamController<ResourceRecord> controller;

  /// The timer for the request.
  Timer timer;
}

/// Class for keeping track of pending lookups and process incoming
/// query responses.
class LookupResolver {
  /// The requests the process.
  final LinkedList<PendingRequest> pendingRequests =
      LinkedList<PendingRequest>();

  /// Adds a request and returns a [Stream] of [ResourceRecord] responses.
  Stream<ResourceRecord> addPendingRequest(
      int type, String name, Duration timeout) {
    final StreamController<ResourceRecord> controller =
        StreamController<ResourceRecord>();
    final PendingRequest request = PendingRequest(type, name, controller);
    final Timer timer = Timer(timeout, () {
      request.unlink();
      controller.close();
    });
    request.timer = timer;
    pendingRequests.add(request);
    return controller.stream;
  }

  /// Processes responses back to the caller.
  void handleResponse(List<ResourceRecord> response) {
    for (ResourceRecord r in response) {
      final int type = r.rrValue;
      String name = r.name.toLowerCase();
      if (name.endsWith('.')) {
        name = name.substring(0, name.length - 1);
      }

      bool responseMatches(PendingRequest request) {
        String requestName = request.name.toLowerCase();
        // make, e.g. "_http" become "_http._tcp.local".
        if (!requestName.endsWith('local')) {
          if (!requestName.endsWith('._tcp.local') &&
              !requestName.endsWith('._udp.local') &&
              !requestName.endsWith('._tcp') &&
              !requestName.endsWith('.udp')) {
            requestName += '._tcp';
          }
          requestName += '.local';
        }
        return requestName == name &&
            (request.type == type || request.type == RRType.any);
      }

      for (PendingRequest pendingRequest in pendingRequests) {
        if (responseMatches(pendingRequest)) {
          if (pendingRequest.controller.isClosed) {
            return;
          }
          pendingRequest.controller.add(r);
        }
      }
    }
  }

  /// Removes any pending requests and ends processing.
  void clearPendingRequests() {
    while (pendingRequests.isNotEmpty) {
      final PendingRequest request = pendingRequests.first;
      request.unlink();
      request.timer.cancel();
      request.controller.close();
    }
  }
}
