// Copyright (c) 2015, the Fletch project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE.md file.

library mdns.src.constants;

import 'dart:io';

InternetAddress mDnsAddress = new InternetAddress('224.0.0.251');
const int mDnsPort = 5353;

// Offsets into the header. See https://tools.ietf.org/html/rfc1035.
const int idOffset = 0;
const int flagsOffset = 2;
const int qdcountOffset = 4;
const int ancountOffset = 6;
const int nscountOffset = 8;
const int arcountOffset = 10;

const int headerSize = 12;

const int responseFlags = 0x8400;

class RRType {
  static const int A = 1;
  static const int AAAA = 28;
  static const int PTR = 12;
  static const int SRV = 33;
  static const int TXT = 16;
}

class RRClass {
  static const int IN = 1;
}
