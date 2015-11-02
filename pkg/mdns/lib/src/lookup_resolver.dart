// Copyright (c) 2015, the Fletch project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE.md file.

library mdns.src.lookup_resolver;

import 'dart:async';
import 'dart:collection';

import 'package:mdns/src/packet.dart';

class PendingRequest extends LinkedListEntry {
  final String hostname;
  final Completer completer;
  PendingRequest(this.hostname, this.completer);
}

/// Class for keeping track of pending lookups and process incoming
/// query responses.
///
/// Currently the responses are no cached.
class LookupResolver {
  LinkedList pendingRequests = new LinkedList();

  Future addPendingRequest(String hostname, Duration timeout) {
    var completer = new Completer();
    var request = new PendingRequest(hostname, completer);
    pendingRequests.add(request);
    return completer.future.timeout(timeout, onTimeout: () {
      request.unlink();
      return null;
    });
  }

  void handleResponse(List<DecodeResult> response) {
    for (var r in response) {
      var name = r.name.toLowerCase();
      if (name.endsWith('.')) name = name.substring(0, name.length - 1);
      pendingRequests
          .where((pendingRequest) {
            return pendingRequest.hostname.toLowerCase() == name;
          })
          .forEach((pendingRequest) {
                pendingRequest.completer.complete(r.address);
                pendingRequest.unlink();
          });
    }
  }
}
