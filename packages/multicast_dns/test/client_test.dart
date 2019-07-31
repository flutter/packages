// Copyright (c) 2015, the Dartino project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:multicast_dns/multicast_dns.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

void main() {
  test('Can inject datagram socket factory and configure mdns port', () async {
    int lastPort;
    final MockRawDatagramSocket mockRawDatagramSocket = MockRawDatagramSocket();
    final MDnsClient client = MDnsClient(rawDatagramSocketFactory:
        (dynamic host, int port,
            {bool reuseAddress, bool reusePort, int ttl = 1}) async {
      lastPort = port;
      return mockRawDatagramSocket;
    });
    when(mockRawDatagramSocket.address).thenReturn(InternetAddress.anyIPv4);

    await client.start(
        mDnsPort: 1234,
        interfacesFactory: (InternetAddressType type) async =>
            <NetworkInterface>[]);

    expect(lastPort, 1234);
  });
}

class MockRawDatagramSocket extends Mock implements RawDatagramSocket {}
