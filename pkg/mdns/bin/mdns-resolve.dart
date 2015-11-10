// Copyright (c) 2015, the Fletch project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE.md file.

// Example script to illustrate how to use the mdns package to lookup names
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
Please provide an address as argument.

For example:
  dart mdns-resolve.dart [--timeout <timeout>] fletch.local''');
    return;
  }

  var name = arguments.rest[0];

  MDnsClient client = new MDnsClient();
  await client.start();
  var timeout;
  timeout = new Duration(seconds: int.parse(arguments['timeout']));
  await for (ResourceRecord record in
             client.lookup(RRType.A, name, timeout: timeout)) {
    print('Found address (${record.address}).');
  }
  client.stop();
}
