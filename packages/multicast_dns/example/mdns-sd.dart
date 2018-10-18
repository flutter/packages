// Copyright (c) 2015, the Dartino project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Example script to illustrate how to use the mdns package to discover services
// on the local network.

import 'package:args/args.dart';

import 'package:multicast_dns/mdns_client.dart';

void main(List<String> args) async {
  // Parse the command line arguments.
  final ArgParser parser = ArgParser();
  parser.addOption('timeout', abbr: 't', defaultsTo: '5');
  final ArgResults arguments = parser.parse(args);

  if (arguments.rest.length != 1) {
    print('''
Please provide the name of a service as argument.

For example:
  dart mdns-sd.dart  [--timeout <timeout>] _workstation._tcp.local''');
    return;
  }

  final String name = arguments.rest[0];

  final MDnsClient client = MDnsClient();
  await client.start();
  await for (PtrResourceRecord ptr in client.lookup(RRType.ptr, name)) {
    final String domain = ptr.domainName;
    print(ptr);
    await for (SrvResourceRecord srv in client.lookup(RRType.srv, domain)) {
      final String target = srv.target;
      print(srv);
      await client.lookup(RRType.txt, domain).forEach(print);
      await for (IPAddressResourceRecord ip
          in client.lookup(RRType.a, target)) {
        print(ip);
        print('Service instance found at $target (${ip.address}).');
      }
    }
  }
  client.stop();
}
