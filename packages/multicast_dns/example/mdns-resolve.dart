// Copyright (c) 2015, the Dartino project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Example script to illustrate how to use the mdns package to lookup names
// on the local network.

import 'package:multicast_dns/multicast_dns.dart';

Future<void> main(List<String> args) async {
  if (args.length != 1) {
    print('''
Please provide an address as argument.

For example:
  dart mdns-resolve.dart dartino.local''');
    return;
  }

  final String name = args[0];

  final MDnsClient client = MDnsClient();
  await client.start();
  await for (IPAddressResourceRecord record in client
      .lookup<IPAddressResourceRecord>(ResourceRecordQuery.addressIPv4(name))) {
    print('Found address (${record.address}).');
  }

  await for (IPAddressResourceRecord record in client
      .lookup<IPAddressResourceRecord>(ResourceRecordQuery.addressIPv6(name))) {
    print('Found address (${record.address}).');
  }
  client.stop();
}
