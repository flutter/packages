// Copyright (c) 2015, the Dartino project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE.md file.

// Example script to illustrate how to use the mdns package to discover services
// on the local network.

import 'package:args/args.dart';

import '../lib/mdns.dart';

main(List<String> args) async {
  // Parse the command line arguments.
  var parser = new ArgParser();
  parser.addOption('timeout', abbr: 't', defaultsTo: '5');
  var arguments = parser.parse(args);

  if (arguments.rest.length != 1) {
    print('''
Please provide the name of a service as argument.

For example:
  dart mdns-sd.dart  [--timeout <timeout>] _workstation._tcp.local''');
    return;
  }

  var name = arguments.rest[0];

  MDnsClient client = new MDnsClient();
  await client.start();
  await for (ResourceRecord ptr in client.lookup(RRType.PTR, name)) {
    String domain = ptr.domainName;
    await for (ResourceRecord srv in client.lookup(RRType.SRV, domain)) {
      String target = srv.target;
      await for (ResourceRecord ip in client.lookup(RRType.A, target)) {
        print('Service instance found at $target (${ip.address}).');
      }
    }
  }
  client.stop();
}
