// Copyright (c) 2015, the Dartino project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:multicast_dns/src/resource_record.dart';

/// Cache for resource records that have been received.
///
/// There can be multiple entries for the same name and type.
///
/// The cached is updated with a list of records, because it needs to remove
/// all entries that correspond to name and type of the name/type combinations
/// of records that should be updated.  For example, a host may remove one
/// of its IP addresses and report the remaining address as a response - then
/// we need to clear all previous entries for that host before updating the
/// cache.
class ResourceRecordCache {
  /// Creates a new ResourceRecordCache.
  ResourceRecordCache({this.size = 32})
      : buffer = List<ResourceRecord>(size),
        _position = 0;

  /// The records in the cache.
  final List<ResourceRecord> buffer;

  /// The size of the cache.
  final int size;
  int _position;

  /// Update the records in this cache.
  void updateRecords(List<ResourceRecord> records) {
    // TODO(karlklose): include flush bit in the record and only flush if
    // necessary.
    // Clear the cache for all name/type combinations to be updated.
    for (int i = 0; i < size; i++) {
      final ResourceRecord r = buffer[i % size];
      if (r == null) {
        continue;
      }
      for (ResourceRecord record in records) {
        if (r.name == record.name &&
            r.resourceRecordType == record.resourceRecordType) {
          buffer[i % size] = null;
          break;
        }
      }
    }
    // Add therecords.
    for (ResourceRecord record in records) {
      buffer[_position] = record;
      _position = (_position + 1) % size;
    }
  }

  /// Get a record from this cache.
  void lookup<T extends ResourceRecord>(
      String name, int type, List<T> results) {
    assert(ResourceRecordType.debugAssertValid(type));
    final int time = DateTime.now().millisecondsSinceEpoch;
    for (int i = _position + size; i >= _position; i--) {
      final int index = i % size;
      if (buffer[index] is! T) {
        continue;
      }
      final T record = buffer[index];
      if (record.validUntil < time) {
        buffer[index] = null;
      } else if (record.name == name && record.resourceRecordType == type) {
        results.add(record);
      }
    }
  }
}
