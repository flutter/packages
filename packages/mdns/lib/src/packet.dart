// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dart_mdns/src/constants.dart';
import 'package:meta/meta.dart';

// Offsets into the header. See https://tools.ietf.org/html/rfc1035.
const int _kIdOffset = 0;
const int _kFlagsOffset = 2;
const int _kQdcountOffset = 4;
const int _kAncountOffset = 6;
const int _kNscountOffset = 8;
const int _kArcountOffset = 10;
const int _kHeaderSize = 12;

/// Encode an mDNS query packet.
List<int> encodeMDnsQuery(String name, [int type = RRType.a]) {
  final List<List<int>> parts =
      name.split('.').map((String part) => utf8.encode(part)).toList();

  // Calculate the size of the packet.
  int size = _kHeaderSize;
  for (int i = 0; i < parts.length; i++) {
    size += 1 + parts[i].length;
  }

  size += 1; // End with empty part
  size += 4; // Trailer (QTYPE and QCLASS).
  final Uint8List data = Uint8List(size);
  final ByteData bd = ByteData.view(data.buffer);
  // Query identifier - just use 0.
  bd.setUint16(_kIdOffset, 0);
  // Flags - 0 for query.
  bd.setUint16(_kFlagsOffset, 0);
  // Query count.
  bd.setUint16(_kQdcountOffset, 1);
  // Number of answers - 0 for query.
  bd.setUint16(_kAncountOffset, 0);
  // Number of name server records - 0 for query.
  bd.setUint16(_kNscountOffset, 0);
  // Number of resource records - 0 for query.
  bd.setUint16(_kArcountOffset, 0);
  int offset = _kHeaderSize;
  for (int i = 0; i < parts.length; i++) {
    data[offset++] = parts[i].length;
    data.setRange(offset, offset + parts[i].length, parts[i]);
    offset += parts[i].length;
  }

  data[offset] = 0; // Empty part.
  offset++;
  bd.setUint16(offset, type); // QTYPE.
  offset += 2;
  bd.setUint16(
      offset, RRClass.internet | QuestionType.multicast); // QCLASS + QM.

  return data;
}

/// Partial implementation of DNS resource records (RRs).
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

/// Result of reading a Fully Qualified Domain Name (FQDN).
class _FQDNReadResult {
  /// Creates a new FQDN read result.
  _FQDNReadResult(this.fqdnParts, this.bytesRead);

  /// The raw parts of the FQDN.
  final List<String> fqdnParts;

  /// The bytes consumed from the packet for this FQDN.
  final int bytesRead;

  /// Returns the Fully Qualified Domain Name.
  String get fqdn => fqdnParts.join('.');

  @override
  String toString() => fqdn;
}

/// Reads a FQDN from raw packet data.
String readFQDN(List<int> packet, [int offset = 0]) {
  final Uint8List data =
      packet is Uint8List ? packet : Uint8List.fromList(packet);
  final ByteData bd = ByteData.view(data.buffer);

  return _readFQDN(data, bd, offset, data.length).fqdn;
}

// Read a FQDN at the given offset. Returns a pair with the FQDN
// parts and the number of bytes consumed.
//
// If decoding fails (e.g. due to an invalid packet) `null` is returned.
_FQDNReadResult _readFQDN(Uint8List data, ByteData bd, int offset, int length) {
  void checkLength(int required) {
    if (length < required) {
      throw MDnsDecodeException(required);
    }
  }

  final List<String> parts = <String>[];
  final int prevOffset = offset;
  while (true) {
    // At least one byte is required.
    checkLength(offset + 1);

    // Check for compressed.
    if (data[offset] & 0xc0 == 0xc0) {
      // At least two bytes are required for a compressed FQDN.
      checkLength(offset + 2);

      // A compressed FQDN has a new offset in the lower 14 bits.
      final _FQDNReadResult result =
          _readFQDN(data, bd, bd.getUint16(offset) & ~0xc000, length);
      parts.addAll(result.fqdnParts);
      offset += 2;
      break;
    } else {
      // A normal FQDN part has a length and a UTF-8 encoded name
      // part. If the length is 0 this is the end of the FQDN.
      final int partLength = data[offset];
      offset++;
      if (partLength > 0) {
        checkLength(offset + partLength);
        final Uint8List partBytes =
            Uint8List.view(data.buffer, offset, partLength);
        offset += partLength;
        parts.add(utf8.decode(partBytes));
      } else {
        break;
      }
    }
  }
  return _FQDNReadResult(parts, offset - prevOffset);
}

/// Decode a mDNS package.
///
/// If decoding fails (e.g. due to an invalid packet) `null` is returned.
///
/// See https://tools.ietf.org/html/rfc1035 for the format.
List<ResourceRecord> decodeMDnsResponse(List<int> packet) {
  final int length = packet.length;
  if (length < _kHeaderSize) {
    return null;
  }

  final Uint8List data = packet is Uint8List ? packet : Uint8List.fromList(packet);
  final ByteData bd = ByteData.view(data.buffer);
  // Number of answers.
  final int ancount = bd.getUint16(_kAncountOffset);
  if (ancount == 0) {
    return null;
  }

  // Number of resource records.
  final int arcount = bd.getUint16(_kArcountOffset);

  int offset = _kHeaderSize;

  void checkLength(int required) {
    if (length < required) {
      throw MDnsDecodeException(required);
    }
  }

  ResourceRecord readResourceRecord() {
    // First read the FQDN.
    final _FQDNReadResult result = _readFQDN(data, bd, offset, length);
    final String fqdn = result.fqdn;
    offset += result.bytesRead;
    checkLength(offset + 2);
    final int type = bd.getUint16(offset);
    offset += 2;
    // The first bit of the rrclass field is set to indicate that the answer is
    // unique and the querier should flush the cached answer for this name
    // (RFC 6762, Sec. 10.2). We ignore it for now since we don't cache answers.
    checkLength(offset + 2);
    final int cls = bd.getUint16(offset) & 0x7fff;

    if (cls != RRClass.internet) {
      // We do not support other classes.
      return null;
    }

    offset += 2;
    checkLength(offset + 4);
    final int ttl = bd.getInt32(offset);
    offset += 4;

    checkLength(offset + 2);
    final int rDataLength = bd.getUint16(offset);
    offset += 2;
    final int validUntil = DateTime.now().millisecondsSinceEpoch + ttl * 1000;
    switch (type) {
      case RRType.a:
        checkLength(offset + rDataLength);
        final Uint8List rawAddress =
            Uint8List.view(data.buffer, offset, rDataLength);
        final String addr = rawAddress.map((int n) => n.toString()).join('.');
        offset += rDataLength;
        return IPAddressResourceRecord(fqdn, validUntil,
            address: InternetAddress(addr));
      case RRType.aaaa:
        checkLength(offset + rDataLength);
        final Uint8List rawAddress =
            Uint8List.view(data.buffer, offset, rDataLength);

        final StringBuffer addr = StringBuffer();
        for (int i = 0; i < rawAddress.length; i += 2) {
          if (i != 0) {
            addr.write(':');
          }
          addr.write(rawAddress[i].toRadixString(16).padLeft(2, '0'));
          addr.write(rawAddress[i + 1].toRadixString(16).padLeft(2, '0'));
        }

        offset += rDataLength;
        return IPAddressResourceRecord(
          fqdn,
          validUntil,
          address: InternetAddress(addr.toString()),
        );
      case RRType.srv:
        checkLength(offset + 2);
        final int priority = bd.getUint16(offset);
        offset += 2;
        checkLength(offset + 2);
        final int weight = bd.getUint16(offset);
        offset += 2;
        checkLength(offset + 2);
        final int port = bd.getUint16(offset);
        offset += 2;
        final _FQDNReadResult result = _readFQDN(data, bd, offset, length);
        offset += rDataLength - 6;
        return SrvResourceRecord(
          fqdn,
          validUntil,
          target: result.fqdn,
          port: port,
          priority: priority,
          weight: weight,
        );
        break;
      case RRType.ptr:
        checkLength(offset + rDataLength);
        final _FQDNReadResult result = _readFQDN(data, bd, offset, length);
        offset += rDataLength;
        return PtrResourceRecord(
          fqdn,
          validUntil,
          domainName: result.fqdn,
        );
      case RRType.txt:
        checkLength(offset + rDataLength);
        final Uint8List rawText = Uint8List.view(
          data.buffer,
          offset,
          rDataLength,
        );
        final String text = utf8.decode(rawText);
        offset += rDataLength;
        return TxtResourceRecord(fqdn, validUntil, text: text);
      default:
        checkLength(offset + rDataLength);
        offset += rDataLength;
        return null;
    }
  }

  final List<ResourceRecord> result = <ResourceRecord>[];

  try {
    for (int i = 0; i < ancount + arcount; i++) {
      final ResourceRecord record = readResourceRecord();
      if (record != null) {
        result.add(record);
      }
    }
  } on MDnsDecodeException {
    // If decoding fails return null.
    return null;
  }
  return result;
}

/// Exceptions thrown by decoder when the packet is invalid.
class MDnsDecodeException implements Exception {
  /// Creates a new MDnsDecodeException.
  const MDnsDecodeException(this.offset);

  /// The offset in the packet at which the exception occurred.
  final int offset;

  @override
  String toString() => 'Decoding error at $offset';
}
