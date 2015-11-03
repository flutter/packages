// Copyright (c) 2015, the Fletch project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE.md file.

library mdns;

import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'package:mdns/src/native_extension_client.dart';
import 'package:mdns/src/native_protocol_client.dart';

/// Client for DNS lookup using the mDNS protocol.
///
/// This client only support "One-Shot Multicast DNS Queries" as described in
/// section 5.1 of https://tools.ietf.org/html/rfc6762
abstract class MDnsClient {
  // Instantiate Client for DNS lookup using the mDNS protocol.
  //
  // On Mac OS a native extension is used as the mDNSResponder opens the mDNS
  // port in exclusive mode. To test the protocol implementation on Mac OS
  // one can turn off mDNSResponder:
  //
  // sudo launchctl unload -w \
  //     /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist
  //
  // And turn it on again:
  //
  // sudo launchctl load -w \
  //    /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist
  factory MDnsClient() {
    if (Platform.isMacOS) {
      return new NativeExtensionMDnsClient();
    } else {
      return new NativeProtocolMDnsClient();
    }
  }

  /// Start the mDNS client.
  Future start();

  /// Stop the mDNS client.
  void stop();

  /// Lookup [hostname] using mDNS.
  ///
  /// The `hostname` must have the form `single-dns-label.local`,
  /// e.g. `printer.local`.
  ///
  /// If no answer has been received within the specified [timeout]
  /// this method will complete with the value `null`.
  Future<InternetAddress> lookup(
      String hostname, {Duration timeout: const Duration(seconds: 5)});
}

// Simple standalone test.
Future main(List<String> args) async {
  var client = new MDnsClient();
  await client.start();
  var address = await client.lookup(args[0]);
  client.stop();
  print(address);
}
