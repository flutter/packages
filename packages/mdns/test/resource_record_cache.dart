// Copyright (c) 2015, the Dartino project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE.md file.

// Test that the resource record cache works correctly.  In particular, make
// sure that it removes all entries for a name before insertingrecords
// of that name.

import 'dart:io';

import 'package:test/test.dart';
import 'package:dart_mdns/src/constants.dart' show RRType;
import 'package:dart_mdns/src/native_protocol_client.dart'
    show ResourceRecordCache;
import 'package:dart_mdns/src/packet.dart';

int entries(ResourceRecordCache cache) {
  int c = 0;
  for (int i = 0; i < cache.size; i++) {
    if (cache.buffer[i] != null) {
      ++c;
    }
  }
  return c;
}

void main() {
  testOverwrite();
  testTimeout();
}

void testOverwrite() {
  test('Cache can overwrite entries', () {
    final InternetAddress ip1 = InternetAddress('192.168.1.1');
    final InternetAddress ip2 = InternetAddress('192.168.1.2');
    final int valid = DateTime.now().millisecondsSinceEpoch + 86400 * 1000;

    final ResourceRecordCache cache = ResourceRecordCache();

    // Add two different records.
    cache.updateRecords(<ResourceRecord>[
      IPAddressResourceRecord('hest', valid, address: ip1),
      IPAddressResourceRecord('fisk', valid, address: ip2)
    ]);
    expect(entries(cache), 2);

    // Update these records.
    cache.updateRecords(<ResourceRecord>[
      IPAddressResourceRecord('hest', valid, address: ip1),
      IPAddressResourceRecord('fisk', valid, address: ip2)
    ]);
    expect(entries(cache), 2);

    // Add two records with the same name (should remove the old one
    // with that name only.)
    cache.updateRecords(<ResourceRecord>[
      IPAddressResourceRecord('hest', valid, address: ip1),
      IPAddressResourceRecord('hest', valid, address: ip2)
    ]);
    expect(entries(cache), 3);

    // Overwrite the two cached entries with one with the same name.
    cache.updateRecords(<ResourceRecord>[
      IPAddressResourceRecord('hest', valid, address: ip1),
    ]);
    expect(entries(cache), 2);
  });
}

void testTimeout() {
  test('Cache can evict records after timeout', () {
    final InternetAddress ip1 = InternetAddress('192.168.1.1');
    final int valid = DateTime.now().millisecondsSinceEpoch + 86400 * 1000;
    final int notValid = DateTime.now().millisecondsSinceEpoch - 1;

    final ResourceRecordCache cache = ResourceRecordCache();

    cache.updateRecords(
        <ResourceRecord>[IPAddressResourceRecord('hest', valid, address: ip1)]);
    expect(entries(cache), 1);

    cache.updateRecords(<ResourceRecord>[
      IPAddressResourceRecord('fisk', notValid, address: ip1)
    ]);

    List<ResourceRecord> results = <ResourceRecord>[];
    cache.lookup('hest', RRType.a, results);
    expect(results.isEmpty, isFalse);

    results = <ResourceRecord>[];
    cache.lookup('fisk', RRType.a, results);
    expect(results.isEmpty, isTrue);
    expect(entries(cache), 1);
  });
}
