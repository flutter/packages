// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library mdns.src.packet;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:mdns/src/constants.dart';

// Encode a mDNS query packet.
List<int> encodeMDnsQuery(String hostname) {
  List parts = hostname.split('.');

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
  bd.setUint16(offset, 1); // QTYPE.
  offset += 2;
  bd.setUint16(offset, 1); // QCLASS.

  return data;
}

/// FQDN and address decoded from response.
class DecodeResult {
  final String name;
  final InternetAddress address;
  DecodeResult(this.name, this.address);
}

/// Result of reading a FQDN. The FQDN parts and the bytes consumed.
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
List<DecodeResult> decodeMDnsResponse(List<int> packet) {
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

  DecodeResult readAddress() {
    // First read the FQDN.
    FQDNReadResult result = readFQDN(offset);
    var fqdn = result.fqdn.join('.');
    offset += result.bytesRead;
    checkLength(offset + 2);
    int type = bd.getUint16(offset);
    offset += 2;
    checkLength(offset + 2);
    int cls = bd.getUint16(offset);
    offset += 2;
    checkLength(offset + 4);
    int ttl = bd.getInt32(offset);
    offset += 4;
    checkLength(offset + 2);
    int addressLength = bd.getUint16(offset);
    offset += 2;
    checkLength(offset + addressLength);
    var addressBytes = new Uint8List.view(data.buffer, offset, addressLength);
    offset += addressLength;

    if (type == ipV4AddressType && cls == ipV4Class && addressLength == 4) {
      String addr = addressBytes.map((n) => n.toString()).join('.');
      return new DecodeResult(fqdn, new InternetAddress(addr));
    } else {
      return null;
    }
  }

  // We don't use the number of records - just read through all
  // resource records and filter.
  var result = [];
  try {
    while (data.length - offset >= 16) {
      var address = readAddress();
      if (address != null) result.add(address);
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
