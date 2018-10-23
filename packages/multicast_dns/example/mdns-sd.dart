// Copyright (c) 2015, the Dartino project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Example script to illustrate how to use the mdns package to discover services
// on the local network.

import 'package:multicast_dns/mdns_client.dart';

void main(List<String> args) async {
  if (args.isEmpty) {
    print('''
Please provide the name of a service as argument.

For example:
  dart mdns-sd.dart [--verbose] _workstation._tcp.local''');
    return;
  }

  final bool verbose = args.contains('--verbose') || args.contains('-v');
  final String name = args.last;
  final MDnsClient client = MDnsClient();
  await client.start();

  await for (PtrResourceRecord ptr
      in client.lookup(ResourceRecordType.ptr, name)) {
    if (verbose) {
      print(ptr);
    }
    await for (SrvResourceRecord srv
        in client.lookup(ResourceRecordType.srv, ptr.domainName)) {
      if (verbose) {
        print(srv);
      }
      if (verbose) {
        await client
            .lookup(ResourceRecordType.txt, ptr.domainName)
            .forEach(print);
      }
      await for (IPAddressResourceRecord ip
          in client.lookup(ResourceRecordType.a, srv.target)) {
        if (verbose) {
          print(ip);
        }
        print(
            'Service instance found at ${srv.target}:${srv.port} with ${ip.address}.');
      }
      await for (IPAddressResourceRecord ip
          in client.lookup(ResourceRecordType.aaaa, srv.target)) {
        if (verbose) {
          print(ip);
        }
        print(
            'Service instance found at ${srv.target}:${srv.port} with ${ip.address}.');
      }
    }
  }
  client.stop();
}
