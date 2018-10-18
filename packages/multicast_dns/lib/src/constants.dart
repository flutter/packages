// Copyright (c) 2015, the Dartino project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

/// The IPv4 mDNS Address.
InternetAddress mDnsAddressIPv4 = InternetAddress('224.0.0.251');

/// The IPv6 mDNS Address.
InternetAddress mDnsAddressIPv6 = InternetAddress('FF02::FB');

/// The mDNS port.
const int mDnsPort = 5353;

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
