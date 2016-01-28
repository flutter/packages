// Copyright (c) 2015, the Dartino project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE.md file.

// Test that the resource record cache works correctly.  In particular, make
// sure that it removes all entries for a name before inserting new records
// of that name.

import 'dart:io';

import 'package:expect/expect.dart';
import 'package:mdns/src/constants.dart' show RRType;
import 'package:mdns/src/native_protocol_client.dart'
    show ResourceRecordCache;
import 'package:mdns/src/packet.dart';

int entries(ResourceRecordCache cache) {
  int c = 0;
  for (int i = 0; i < cache.size; i++) {
    if (cache.buffer[i] != null) {
      ++c;
    }
  }
  return c;
}

main() {
  testOverwrite();
  testTimeout();
}

testOverwrite() {
  InternetAddress ip1 = new InternetAddress("192.168.1.1");
  InternetAddress ip2 = new InternetAddress("192.168.1.2");
  int valid = new DateTime.now().millisecondsSinceEpoch + 86400 * 1000;

  ResourceRecordCache cache = new ResourceRecordCache();

  // Add two different records.
  cache.updateRecords([
    new ResourceRecord(RRType.A, "hest", ip1, valid),
    new ResourceRecord(RRType.A, "fisk", ip2, valid)]);
  Expect.equals(2, entries(cache));

  // Update these records.
  cache.updateRecords([
    new ResourceRecord(RRType.A, "hest", ip1, valid),
    new ResourceRecord(RRType.A, "fisk", ip2, valid)]);
  Expect.equals(2, entries(cache));

  // Add two records with the same name (should remove the old one
  // with that name only.)
  cache.updateRecords([
    new ResourceRecord(RRType.A, "hest", ip1, valid),
    new ResourceRecord(RRType.A, "hest", ip2, valid)]);
  Expect.equals(3, entries(cache));

  // Overwrite the two cached entries with one with the same name.
  cache.updateRecords([
    new ResourceRecord(RRType.A, "hest", ip1, valid),
  ]);
  Expect.equals(2, entries(cache));
}

testTimeout() {
  InternetAddress ip1 = new InternetAddress("192.168.1.1");
  InternetAddress ip2 = new InternetAddress("192.168.1.2");
  int valid = new DateTime.now().millisecondsSinceEpoch + 86400 * 1000;
  int notValid = new DateTime.now().millisecondsSinceEpoch - 1;

  ResourceRecordCache cache = new ResourceRecordCache();

  cache.updateRecords([
    new ResourceRecord(RRType.A, "hest", ip1, valid)
  ]);
  Expect.equals(1, entries(cache));

  cache.updateRecords([
    new ResourceRecord(RRType.A, "fisk", ip1, notValid)
  ]);

  var results;
  results = [];
  cache.lookup("hest", RRType.A, results);
  Expect.isFalse(results.isEmpty);

  results = [];
  cache.lookup("fisk", RRType.A, results);
  Expect.isTrue(results.isEmpty);
  Expect.equals(1, entries(cache));
}
