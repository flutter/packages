// Copyright (c) 2015, the Dartino project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Example script to illustrate how to use the mdns package to lookup names
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
Please provide an address as argument.

For example:
  dart mdns-resolve.dart [--timeout <timeout>] dartino.local''');
    return;
  }

  final String name = arguments.rest[0];

  final MDnsClient client = MDnsClient();
  await client.start();
  final Duration timeout = Duration(seconds: int.parse(arguments['timeout']));
  await for (IPAddressResourceRecord record
      in client.lookup(RRType.a, name, timeout: timeout)) {
    print('Found address (${record.address}).');
  }
  client.stop();
}
