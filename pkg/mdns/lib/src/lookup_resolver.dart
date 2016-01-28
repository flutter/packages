// Copyright (c) 2015, the Dartino project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE.md file.

library mdns.src.lookup_resolver;

import 'dart:async';
import 'dart:collection';

import 'package:mdns/src/packet.dart';

class PendingRequest extends LinkedListEntry {
  final int type;
  final String name;
  final StreamController controller;
  Timer timer;

  PendingRequest(this.type, this.name, this.controller);
}

/// Class for keeping track of pending lookups and process incoming
/// query responses.
class LookupResolver {
  LinkedList pendingRequests = new LinkedList();

  Stream<ResourceRecord> addPendingRequest(
      int type,
      String name,
      Duration timeout) {
    StreamController controller = new StreamController();
    PendingRequest request = new PendingRequest(type, name, controller);
    Timer timer = new Timer(timeout, () {
      request.unlink();
      controller.close();
    });
    request.timer = timer;
    pendingRequests.add(request);
    return controller.stream;
  }

  void handleResponse(List<ResourceRecord> response) {
    for (ResourceRecord r in response) {
      int type = r.type;
      String name = r.name.toLowerCase();
      if (name.endsWith('.')) name = name.substring(0, name.length - 1);

      bool responseMatches(PendingRequest request) {
        return request.name.toLowerCase() == name &&
          request.type == type;
      }

      pendingRequests.where(responseMatches).forEach((pendingRequest) {
        if (pendingRequest.controller.isClosed) return;
        pendingRequest.controller.add(r);
      });
    }
  }

  void clearPendingRequests() {
    while (pendingRequests.isNotEmpty) {
      PendingRequest request = pendingRequests.first;
      request.unlink();
      request.timer.cancel();
      request.controller.close();
    }
  }
}
