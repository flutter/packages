// Copyright 2018 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:io';

import 'package:meta/meta.dart';

/// Enumeration of support resource record types.
class RRType {
  /// An IPv4 Address record (1).
  static const int a = 1;

  /// An IPv6 Address record (28).
  static const int aaaa = 28;

  /// An IP Address reverse map record (12).
  static const int ptr = 12;

  /// An available service record (33).
  static const int srv = 33;

  /// A text record (16).
  static const int txt = 16;

  // TODO(dnfield): Can we support ANY in some meaningful way?
  // /// A query for all records of all types known to the name server.
  // static const int any = 255;

  /// Asserts that a given int is a valid RRType.
  static void debugAssertValid(int rrType) {
    assert(rrType == a ||
        rrType == aaaa ||
        rrType == ptr ||
        rrType == srv ||
        rrType == txt);
  }
}

/// Base implementation of DNS resource records (RRs).
abstract class ResourceRecord {
  /// Creates a new ResourceRecord.
  ResourceRecord(this.rrValue, this.name, this.validUntil);

  /// The FQDN for this record.
  final String name;

  /// The epoch time at which point this record is valid for in the cache.
  final int validUntil;

  /// The raw resource record value.  See [RRType] for supported values.
  final int rrValue;

  String get _additionalInfo;

  @override
  String toString() =>
      '$runtimeType{$name, validUntil: ${DateTime.fromMillisecondsSinceEpoch(validUntil)}, $_additionalInfo}';

  @override
  bool operator ==(Object other) {
    return other is ResourceRecord && _equals(other);
  }

  @protected
  bool _equals(ResourceRecord other) {
    return other.name == name &&
        other.validUntil == validUntil &&
        other.rrValue == rrValue;
  }

  @override
  int get hashCode {
    // TODO(dnfield): Probably should go with a real hashing function here
    // when https://github.com/dart-lang/sdk/issues/11617 is figured out.
    return toString().hashCode;
  }
}

/// A Service Pointer for reverse mapping an IP address (DNS "PTR").
class PtrResourceRecord extends ResourceRecord {
  /// Creates a new PtrResourceRecord.
  PtrResourceRecord(
    String name,
    int validUntil, {
    @required this.domainName,
  }) : super(RRType.ptr, name, validUntil);

  /// The FQDN for this record.
  final String domainName;

  @override
  String get _additionalInfo => 'domainName: $domainName';

  @override
  bool _equals(ResourceRecord other) {
    return other is PtrResourceRecord &&
        other.domainName == domainName &&
        super._equals(other);
  }
}

/// An IP Address record for IPv4 (DNS "A") or IPv6 (DNS "AAAA") records.
class IPAddressResourceRecord extends ResourceRecord {
  /// Creates a new IPAddressResourceRecord.
  IPAddressResourceRecord(
    String name,
    int validUntil, {
    @required this.address,
  }) : super(address.type == InternetAddressType.IPv4 ? RRType.a : RRType.aaaa,
            name, validUntil);

  /// The [InternetAddress] for this record.
  final InternetAddress address;

  @override
  String get _additionalInfo => 'address: $address';

  @override
  bool _equals(ResourceRecord other) {
    return other is IPAddressResourceRecord && other.address == address;
  }
}

/// A Service record, capturing a host target and port (DNS "SRV").
class SrvResourceRecord extends ResourceRecord {
  /// Creates a new service record.
  SrvResourceRecord(
    String name,
    int validUntil, {
    @required this.target,
    @required this.port,
    @required this.priority,
    @required this.weight,
  }) : super(RRType.srv, name, validUntil);

  /// The hostname for this record.
  final String target;

  /// The port for this record.
  final int port;

  /// The relative priority of this service.
  final int priority;

  /// The weight (used when multiple services have the same priority).
  final int weight;

  @override
  String get _additionalInfo =>
      'target: $target, port: $port, priority: $priority, weight: $weight';

  @override
  bool _equals(ResourceRecord other) {
    return other is SrvResourceRecord &&
        other.target == target &&
        other.port == port &&
        other.priority == priority &&
        other.weight == weight;
  }
}

/// A Text record, contianing additional textual data (DNS "TXT").
class TxtResourceRecord extends ResourceRecord {
  /// Creates a new text record.
  TxtResourceRecord(
    String name,
    int validUntil, {
    @required this.text,
  }) : super(RRType.txt, name, validUntil);

  /// The raw text from this record.
  final String text;

  @override
  String get _additionalInfo => 'text: $text';

  @override
  bool _equals(ResourceRecord other) {
    return other is TxtResourceRecord && other.text == text;
  }
}
