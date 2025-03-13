// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:multicast_dns/multicast_dns.dart';
import 'package:test/fake.dart';
import 'package:test/test.dart';

void main() {
  test('Can inject datagram socket factory and configure mdns port', () async {
    late int lastPort;
    final FakeRawDatagramSocket datagramSocket = FakeRawDatagramSocket();
    final MDnsClient client = MDnsClient(rawDatagramSocketFactory:
        (dynamic host, int port,
            {bool reuseAddress = true,
            bool reusePort = true,
            int ttl = 1}) async {
      lastPort = port;
      return datagramSocket;
    });

    await client.start(
        mDnsPort: 1234,
        interfacesFactory: (InternetAddressType type) async =>
            <NetworkInterface>[]);

    expect(lastPort, 1234);
  });

  test('Closes IPv4 sockets', () async {
    final FakeRawDatagramSocket datagramSocket = FakeRawDatagramSocket();
    final MDnsClient client = MDnsClient(rawDatagramSocketFactory:
        (dynamic host, int port,
            {bool reuseAddress = true,
            bool reusePort = true,
            int ttl = 1}) async {
      return datagramSocket;
    });

    await client.start(
        mDnsPort: 1234,
        interfacesFactory: (InternetAddressType type) async =>
            <NetworkInterface>[]);
    expect(datagramSocket.closed, false);
    client.stop();
    expect(datagramSocket.closed, true);
  });

  test('Closes IPv6 sockets', () async {
    final FakeRawDatagramSocket datagramSocket = FakeRawDatagramSocket();
    datagramSocket.address = InternetAddress.anyIPv6;
    final MDnsClient client = MDnsClient(rawDatagramSocketFactory:
        (dynamic host, int port,
            {bool reuseAddress = true,
            bool reusePort = true,
            int ttl = 1}) async {
      return datagramSocket;
    });

    await client.start(
        mDnsPort: 1234,
        interfacesFactory: (InternetAddressType type) async =>
            <NetworkInterface>[]);
    expect(datagramSocket.closed, false);
    client.stop();
    expect(datagramSocket.closed, true);
  });

  test('start() is idempotent', () async {
    final FakeRawDatagramSocket datagramSocket = FakeRawDatagramSocket();
    datagramSocket.address = InternetAddress.anyIPv4;
    final MDnsClient client = MDnsClient(rawDatagramSocketFactory:
        (dynamic host, int port,
            {bool reuseAddress = true,
            bool reusePort = true,
            int ttl = 1}) async {
      return datagramSocket;
    });

    await client.start(
        interfacesFactory: (InternetAddressType type) async =>
            <NetworkInterface>[]);
    await client.start();
    await client.lookup(ResourceRecordQuery.serverPointer('_')).toList();
  });

  group('Bind a single socket to ANY IPv4 and more than one when IPv6', () {
    final List<Map<String, Object>> testCases = <Map<String, Object>>[
      <String, Object>{
        'name': 'IPv4',
        'datagramSocketType': InternetAddress.anyIPv4,
        'interfacePrefix': '192.168.2.'
      },
      <String, Object>{
        'name': 'IPv6',
        'datagramSocketType': InternetAddress.anyIPv6,
        'interfacePrefix': '2001:0db8:85a3:0000:0000:8a2e:7335:030'
      }
    ];

    for (final Map<String, Object> testCase in testCases) {
      test('Bind a single socket to ANY ${testCase["name"]}', () async {
        final FakeRawDatagramSocket datagramSocket = FakeRawDatagramSocket();

        datagramSocket.address =
            testCase['datagramSocketType']! as InternetAddress;

        final List<dynamic> selectedInterfacesForSendingPackets = <dynamic>[];
        final MDnsClient client = MDnsClient(rawDatagramSocketFactory:
            (dynamic host, int port,
                {bool reuseAddress = true,
                bool reusePort = true,
                int ttl = 1}) async {
          selectedInterfacesForSendingPackets.add(host);
          return datagramSocket;
        });

        const int numberOfFakeInterfaces = 10;
        Future<Iterable<NetworkInterface>> fakeNetworkInterfacesFactory(
            InternetAddressType type) async {
          final List<NetworkInterface> fakeInterfaces = <NetworkInterface>[];

          // Generate "fake" interfaces
          for (int i = 0; i < numberOfFakeInterfaces; i++) {
            fakeInterfaces.add(FakeNetworkInterface(
              'inetfake$i',
              <InternetAddress>[
                InternetAddress("${testCase['interfacePrefix']! as String}$i")
              ],
              0,
            ));
          }

          // ignore: always_specify_types
          return Future.value(fakeInterfaces);
        }

        final InternetAddress listenAddress =
            testCase['datagramSocketType']! as InternetAddress;

        await client.start(
            listenAddress: listenAddress,
            mDnsPort: 1234,
            interfacesFactory: fakeNetworkInterfacesFactory);
        client.stop();

        if (testCase['datagramSocketType'] == InternetAddress.anyIPv4) {
          expect(selectedInterfacesForSendingPackets.length, 1);
        } else {
          // + 1 because of unspecified address (::)
          expect(selectedInterfacesForSendingPackets.length,
              numberOfFakeInterfaces + 1);
        }
        expect(selectedInterfacesForSendingPackets[0], listenAddress.address);
      });
    }
  });
}

class FakeRawDatagramSocket extends Fake implements RawDatagramSocket {
  @override
  InternetAddress address = InternetAddress.anyIPv4;

  @override
  StreamSubscription<RawSocketEvent> listen(
      void Function(RawSocketEvent event)? onData,
      {Function? onError,
      void Function()? onDone,
      bool? cancelOnError}) {
    return const Stream<RawSocketEvent>.empty().listen(onData,
        onError: onError, cancelOnError: cancelOnError, onDone: onDone);
  }

  bool closed = false;

  @override
  void close() {
    closed = true;
  }

  @override
  int send(List<int> buffer, InternetAddress address, int port) {
    return buffer.length;
  }

  @override
  void joinMulticast(InternetAddress group, [NetworkInterface? interface]) {
    // nothing to do here
  }
  @override
  void setRawOption(RawSocketOption option) {
    // nothing to do here
  }
}

class FakeNetworkInterface implements NetworkInterface {
  FakeNetworkInterface(this._name, this._addresses, this._index);

  final String _name;
  final List<InternetAddress> _addresses;
  final int _index;

  @override
  List<InternetAddress> get addresses => _addresses;

  @override
  String get name => _name;

  @override
  int get index => _index;
}
