// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library mdns.src.packet;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:mdns/src/constants.dart';

// Encode a mDNS query packet.
List<int> encodeMDnsQuery(String name, [int type = RRType.A]) {
  List parts = name.split('.');

  // Calculate the size of the packet.
  int size = headerSize;
  for (int i = 0; i < parts.length; i++) {
    parts[i] = UTF8.encode(parts[i]);
    size += 1 + parts[i].length;
  }
  size += 1; // End with empty part
  size += 4; // Trailer (QTYPE and QCLASS).
  Uint8List data = new Uint8List(size);
  ByteData bd = new ByteData.view(data.buffer);
  // Query identifier - just use 0.
  bd.setUint16(idOffset, 0);
  // Flags - 0 for query.
  bd.setUint16(flagsOffset, 0);
  // Query count.
  bd.setUint16(qdcountOffset, 1);
  // Number of answers - 0 for query.
  bd.setUint16(ancountOffset, 0);
  // Number of name server records - 0 for query.
  bd.setUint16(nscountOffset, 0);
  // Number of resource records - 0 for query.
  bd.setUint16(arcountOffset, 0);
  int offset = headerSize;
  for (int i = 0; i < parts.length; i++) {
    data[offset++] = parts[i].length;
    data.setRange(offset, offset + parts[i].length, parts[i]);
    offset += parts[i].length;
  }
  data[offset] = 0; // Empty part.
  offset++;
  bd.setUint16(offset, type); // QTYPE.
  offset += 2;
  bd.setUint16(offset, RRClass.IN | 0x8000); // QCLASS + QU.

  return data;
}

/// Partial implementation of DNS resource records (RRs).
class ResourceRecord {
  final int type;
  final String name;
  final _data;
  final int validUntil;
  // TODO(karlklose): add missing header bits.

  ResourceRecord(this.type, this.name, this._data, this.validUntil);

  InternetAddress get address {
    if (type != RRType.A) {
      // TODO(karlklose): add IPv6 address support.
      throw new StateError("'address' is only supported for type A.");
    }
    return _data;
  }

  String get domainName {
    if (type != RRType.PTR) {
      throw new StateError("'domain name' is only supported for type PTR.");
    }
    return _data;
  }

  String get target {
    if (type != RRType.SRV) {
      throw new StateError("'target' is only supported for type SRV.");
    }
    return _data;
  }

  toString() => 'RR $type $_data';
}

/// Result of reading a FQDN.
class FQDNReadResult {
  final List<String> fqdn;
  final int bytesRead;
  FQDNReadResult(this.fqdn, this.bytesRead);
}

/// Decode a mDNS package.
///
/// If decoding fails (e.g. due to an invalid packet) `null` is returned.
///
/// See https://tools.ietf.org/html/rfc1035 for the format.
List<ResourceRecord> decodeMDnsResponse(List<int> packet) {
  int length = packet.length;
  if (length < headerSize) return null;

  Uint8List data =
      packet is Uint8List ? packet : new Uint8List.fromList(packet);
  ByteData bd = new ByteData.view(data.buffer);
  // Query identifier.
  int id = bd.getUint16(idOffset);
  // Flags.
  int flags = bd.getUint16(flagsOffset);

  if (flags != responseFlags) return null;
  // Query count.
  int qdcount = bd.getUint16(qdcountOffset);
  // Number of answers.
  int ancount = bd.getUint16(ancountOffset);
  // Number of name server records.
  int nscount = bd.getUint16(nscountOffset);
  // Number of resource records.
  int arcount = bd.getUint16(arcountOffset);
  int offset = headerSize;

  void checkLength(int required) {
    if (length < required) throw new MDnsDecodeException(required);
  }

  // Read a FQDN at the given offset. Returns a pair with the FQDN
  // parts and the number of bytes consumed.
  //
  // If decoding fails (e.g. due to an invalid packet) `null` is returned.
  FQDNReadResult readFQDN(int offset) {
    List<String> parts = [];
    int prevOffset = offset;
    while (true) {
      // At least two bytes required.
      checkLength(offset + 2);

      // Check for compressed.
      if (data[offset] & 0xc0 == 0xc0) {
        // A compressed FQDN has a new offset in the lower 14 bits.
        FQDNReadResult result = readFQDN(bd.getUint16(offset) & ~0xc000);
        parts.addAll(result.fqdn);
        offset += 2;
        break;
      } else {
        // A normal FQDN part has a length and a UTF-8 encoded name
        // part. If the length is 0 this is the end of the FQDN.
        var partLength = data[offset];
        offset++;
        if (partLength != 0) {
          checkLength(offset + partLength);
          var partBytes = new Uint8List.view(data.buffer, offset, partLength);
          offset += partLength;
          parts.add(UTF8.decode(partBytes));
        } else {
          break;
        }
      }
    }
    return new FQDNReadResult(parts, offset - prevOffset);
  }

  ResourceRecord readResourceRecord() {
    // First read the FQDN.
    FQDNReadResult result = readFQDN(offset);
    var fqdn = result.fqdn.join('.');
    offset += result.bytesRead;
    checkLength(offset + 2);
    int type = bd.getUint16(offset);
    offset += 2;
    // The first bit of the rrclass field is set to indicate that the answer is
    // unique and the querier should flush the cached answer for this name
    // (RFC 6762, Sec. 10.2). We ignore it for now since we don't cache answers.
    checkLength(offset + 2);
    int cls = bd.getUint16(offset) & 0x7fff;
    offset += 2;
    checkLength(offset + 4);
    int ttl = bd.getInt32(offset);
    offset += 4;

    var rData;
    checkLength(offset + 2);
    int rDataLength = bd.getUint16(offset);
    offset += 2;
    switch (type) {
      case RRType.A:
        checkLength(offset + rDataLength);
        rData = new Uint8List.view(data.buffer, offset, rDataLength);
        String addr = rData.map((n) => n.toString()).join('.');
        rData = new InternetAddress(addr);
        offset += rDataLength;
        break;
      case RRType.SRV:
        checkLength(offset + 2);
        int priority = bd.getUint16(offset);
        offset += 2;
        checkLength(offset + 2);
        int weight = bd.getUint16(offset);
        offset += 2;
        checkLength(offset + 2);
        int port = bd.getUint16(offset);
        offset += 2;
        FQDNReadResult result = readFQDN(offset);
        rData = result.fqdn.join('.');
        offset += rDataLength - 6;
        break;
      case RRType.PTR:
        checkLength(offset + rDataLength);
        FQDNReadResult result = readFQDN(offset);
        offset += rDataLength;
        rData = result.fqdn.join('.');
        break;
      case RRType.TXT:
        // TODO(karlklose): convert to a String or Map.
      default:
        checkLength(offset + rDataLength);
        rData = new Uint8List.view(data.buffer, offset, rDataLength);
        offset += rDataLength;
        break;
    }
    assert(rData != null);

    if (cls != RRClass.IN) {
      // We do not support other classes at the moment.
      return null;
    }

    int validUntil = new DateTime.now().millisecondsSinceEpoch +
      ttl * 1000;
    return new ResourceRecord(type, fqdn, rData, validUntil);
  }

  List<ResourceRecord> result = <ResourceRecord>[];
  try {
    for (int i = 0; i < ancount; i++) {
      ResourceRecord record = readResourceRecord();
      if (record != null) {
        result.add(record);
      }
    }
  } on MDnsDecodeException catch (e, s) {
    // If decoding fails return null.
    return null;
  }
  return result;
}

/// Exceptions thrown by decoder when the packet is invalid.
class MDnsDecodeException implements Exception {
  /// Exception message.
  final int offset;
  const MDnsDecodeException(this.offset);
  String toString() => 'Decoding error at $offset';
}
