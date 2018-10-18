// Copyright (c) 2015, the Dartino project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE.md file.

import 'dart:io';

/// The IPv4 mDNS Address.
InternetAddress mDnsAddress = InternetAddress('224.0.0.251');

/// The mDNS port.
const int mDnsPort = 5353;

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
}

/// Enumeration of supported resource record class types.
class RRClass {
  /// Internet address class ("IN").
  static const int internet = 1;
}

/// Enumeration of DNS question types.
class QuestionType {
  /// "QU" Question.
  static const int unicast = 0x8000;

  /// "QM" Question.
  static const int multicast = 0x0000;
}
