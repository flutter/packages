// Copyright (c) 2015, the Fletch project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE.md file.

import 'package:expect/expect.dart';
import 'package:mdns/src/constants.dart';
import 'package:mdns/src/packet.dart';

main() {
  testValidPackages();
  testBadPackages();
  testHexDumpList();
  testPTRRData();
  testSRVRData();
}

testValidPackages() {
  var result;
  result = decodeMDnsResponse(package1);
  Expect.equals(1, result.length);
  Expect.equals('raspberrypi.local', result[0].name);
  Expect.equals('192.168.1.191', result[0].address.address);

  result = decodeMDnsResponse(package2);
  Expect.equals(2, result.length);
  Expect.equals('raspberrypi.local', result[0].name);
  Expect.equals('192.168.1.191', result[0].address.address);
  Expect.equals('raspberrypi.local', result[1].name);
  Expect.equals('169.254.95.83', result[1].address.address);

  result = decodeMDnsResponse(package3);
  Expect.equals(8, result.length);
  Expect.equals("""
RR 16 [0]
RR 12 raspberrypi._udisks-ssh._tcp.local
RR 33 raspberrypi.local
RR 16 [0]
RR 12 _udisks-ssh._tcp.local
RR 12 raspberrypi [b8:27:eb:03:92:4b]._workstation._tcp.local
RR 33 raspberrypi.local
RR 12 _workstation._tcp.local""",
      result.join('\n'));

  result = decodeMDnsResponse(packagePtrResponse);
  Expect.equals(6, result.length);
  Expect.equals("""
RR 12 fletch-agent on raspberrypi._fletch_agent._tcp.local
RR 16 [0]
RR 33 raspberrypi.local
RR 28 [254, 128, 0, 0, 0, 0, 0, 0, 186, 39, 235, 255, 254, 105, 110, 58]
RR 1 InternetAddress('192.168.1.1', IP_V4)
RR 1 InternetAddress('169.254.167.172', IP_V4)""",
      result.join('\n'));
}

testBadPackages() {
  for (var p in [package1, package2, package3]) {
    for (int i = 0; i < p.length; i++) {
      decodeMDnsResponse(p.sublist(0, i));
    }
  }
}

testPTRRData() {
  Expect.equals(
    'sgjesse-macbookpro2 [78:31:c1:b8:55:38]._workstation._tcp.local',
    readFQDN(ptrRData));
    print(readFQDN(ptrRData2));
  Expect.equals('fletch-agent._fletch_agent._tcp.local', readFQDN(ptrRData2));
}

testSRVRData() {
  Expect.equals('fletch.local', readFQDN(srvRData, srvHeaderSize));
}

testHexDumpList() {
  // Call hexDumpList to get rid of hint.
  formatHexStream("");
  hexDumpList([]);
}

// One address.
var package1 = [
    0x00, 0x00, 0x84, 0x00, 0x00, 0x00, 0x00, 0x01,
    0x00, 0x00, 0x00, 0x00, 0x0b, 0x72, 0x61, 0x73,
    0x70, 0x62, 0x65, 0x72, 0x72, 0x79, 0x70, 0x69,
    0x05, 0x6c, 0x6f, 0x63, 0x61, 0x6c, 0x00, 0x00,
    0x01, 0x80, 0x01, 0x00, 0x00, 0x00, 0x78, 0x00,
    0x04, 0xc0, 0xa8, 0x01, 0xbf];

// Two addresses.
var package2 = [
    0x00, 0x00, 0x84, 0x00, 0x00, 0x00, 0x00, 0x02,
    0x00, 0x00, 0x00, 0x00, 0x0b, 0x72, 0x61, 0x73,
    0x70, 0x62, 0x65, 0x72, 0x72, 0x79, 0x70, 0x69,
    0x05, 0x6c, 0x6f, 0x63, 0x61, 0x6c, 0x00, 0x00,
    0x01, 0x80, 0x01, 0x00, 0x00, 0x00, 0x78, 0x00,
    0x04, 0xc0, 0xa8, 0x01, 0xbf, 0xc0, 0x0c, 0x00,
    0x01, 0x80, 0x01, 0x00, 0x00, 0x00, 0x78, 0x00,
    0x04, 0xa9, 0xfe, 0x5f, 0x53];

// Eight mixed answers.
var package3 = [
    0x00, 0x00, 0x84, 0x00, 0x00, 0x00, 0x00, 0x08,
    0x00, 0x00, 0x00, 0x00, 0x1f, 0x72, 0x61, 0x73,
    0x70, 0x62, 0x65, 0x72, 0x72, 0x79, 0x70, 0x69,
    0x20, 0x5b, 0x62, 0x38, 0x3a, 0x32, 0x37, 0x3a,
    0x65, 0x62, 0x3a, 0x30, 0x33, 0x3a, 0x39, 0x32,
    0x3a, 0x34, 0x62, 0x5d, 0x0c, 0x5f, 0x77, 0x6f,
    0x72, 0x6b, 0x73, 0x74, 0x61, 0x74, 0x69, 0x6f,
    0x6e, 0x04, 0x5f, 0x74, 0x63, 0x70, 0x05, 0x6c,
    0x6f, 0x63, 0x61, 0x6c, 0x00, 0x00, 0x10, 0x80,
    0x01, 0x00, 0x00, 0x11, 0x94, 0x00, 0x01, 0x00,
    0x0b, 0x5f, 0x75, 0x64, 0x69, 0x73, 0x6b, 0x73,
    0x2d, 0x73, 0x73, 0x68, 0xc0, 0x39, 0x00, 0x0c,
    0x00, 0x01, 0x00, 0x00, 0x11, 0x94, 0x00, 0x0e,
    0x0b, 0x72, 0x61, 0x73, 0x70, 0x62, 0x65, 0x72,
    0x72, 0x79, 0x70, 0x69, 0xc0, 0x50, 0xc0, 0x68,
    0x00, 0x21, 0x80, 0x01, 0x00, 0x00, 0x00, 0x78,
    0x00, 0x14, 0x00, 0x00, 0x00, 0x00, 0x00, 0x16,
    0x0b, 0x72, 0x61, 0x73, 0x70, 0x62, 0x65, 0x72,
    0x72, 0x79, 0x70, 0x69, 0xc0, 0x3e, 0xc0, 0x68,
    0x00, 0x10, 0x80, 0x01, 0x00, 0x00, 0x11, 0x94,
    0x00, 0x01, 0x00, 0x09, 0x5f, 0x73, 0x65, 0x72,
    0x76, 0x69, 0x63, 0x65, 0x73, 0x07, 0x5f, 0x64,
    0x6e, 0x73, 0x2d, 0x73, 0x64, 0x04, 0x5f, 0x75,
    0x64, 0x70, 0xc0, 0x3e, 0x00, 0x0c, 0x00, 0x01,
    0x00, 0x00, 0x11, 0x94, 0x00, 0x02, 0xc0, 0x50,
    0xc0, 0x2c, 0x00, 0x0c, 0x00, 0x01, 0x00, 0x00,
    0x11, 0x94, 0x00, 0x02, 0xc0, 0x0c, 0xc0, 0x0c,
    0x00, 0x21, 0x80, 0x01, 0x00, 0x00, 0x00, 0x78,
    0x00, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x09,
    0xc0, 0x88, 0xc0, 0xa3, 0x00, 0x0c, 0x00, 0x01,
    0x00, 0x00, 0x11, 0x94, 0x00, 0x02, 0xc0, 0x2c];

var packagePtrResponse = <int>[
  0x00, 0x00, 0x84, 0x00, 0x00, 0x00, 0x00, 0x06,
  0x00, 0x00, 0x00, 0x00, 0x0d, 0x5f, 0x66, 0x6c,
  0x65, 0x74, 0x63, 0x68, 0x5f, 0x61, 0x67, 0x65,
  0x6e, 0x74, 0x04, 0x5f, 0x74, 0x63, 0x70, 0x05,
  0x6c, 0x6f, 0x63, 0x61, 0x6c, 0x00, 0x00, 0x0c,
  0x00, 0x01, 0x00, 0x00, 0x11, 0x94, 0x00, 0x1e,
  0x1b, 0x66, 0x6c, 0x65, 0x74, 0x63, 0x68, 0x2d,
  0x61, 0x67, 0x65, 0x6e, 0x74, 0x20, 0x6f, 0x6e,
  0x20, 0x72, 0x61, 0x73, 0x70, 0x62, 0x65, 0x72,
  0x72, 0x79, 0x70, 0x69, 0xc0, 0x0c, 0xc0, 0x30,
  0x00, 0x10, 0x80, 0x01, 0x00, 0x00, 0x11, 0x94,
  0x00, 0x01, 0x00, 0xc0, 0x30, 0x00, 0x21, 0x80,
  0x01, 0x00, 0x00, 0x00, 0x78, 0x00, 0x14, 0x00,
  0x00, 0x00, 0x00, 0x2f, 0x59, 0x0b, 0x72, 0x61,
  0x73, 0x70, 0x62, 0x65, 0x72, 0x72, 0x79, 0x70,
  0x69, 0xc0, 0x1f, 0xc0, 0x6d, 0x00, 0x1c, 0x80,
  0x01, 0x00, 0x00, 0x00, 0x78, 0x00, 0x10, 0xfe,
  0x80, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xba,
  0x27, 0xeb, 0xff, 0xfe, 0x69, 0x6e, 0x3a, 0xc0,
  0x6d, 0x00, 0x01, 0x80, 0x01, 0x00, 0x00, 0x00,
  0x78, 0x00, 0x04, 0xc0, 0xa8, 0x01, 0x01, 0xc0,
  0x6d, 0x00, 0x01, 0x80, 0x01, 0x00, 0x00, 0x00,
  0x78, 0x00, 0x04, 0xa9, 0xfe, 0xa7, 0xac
];

var ptrRData = <int>[
  0x27, 0x73, 0x67, 0x6a, 0x65, 0x73, 0x73, 0x65,
  0x2d, 0x6d, 0x61, 0x63, 0x62, 0x6f, 0x6f, 0x6b,
  0x70, 0x72, 0x6f, 0x32, 0x20, 0x5b, 0x37, 0x38,
  0x3a, 0x33, 0x31, 0x3a, 0x63, 0x31, 0x3a, 0x62,
  0x38, 0x3a, 0x35, 0x35, 0x3a, 0x33, 0x38, 0x5d,
  0x0c, 0x5f, 0x77, 0x6f, 0x72, 0x6b, 0x73, 0x74,
  0x61, 0x74, 0x69, 0x6f, 0x6e, 0x04, 0x5f, 0x74,
  0x63, 0x70, 0x05, 0x6c, 0x6f, 0x63, 0x61, 0x6c,
  0x00
];

var ptrRData2 = <int>[
  0x0c, 0x66, 0x6c, 0x65, 0x74, 0x63, 0x68, 0x2d,
  0x61, 0x67, 0x65, 0x6e, 0x74, 0x0d, 0x5f, 0x66,
  0x6c, 0x65, 0x74, 0x63, 0x68, 0x5f, 0x61, 0x67,
  0x65, 0x6e, 0x74, 0x04, 0x5f, 0x74, 0x63, 0x70,
  0x05, 0x6c, 0x6f, 0x63, 0x61, 0x6c, 0x00
];

var srvRData = <int> [
  0x00, 0x00, 0x00, 0x00, 0x2f, 0x59, 0x06, 0x66,
  0x6c, 0x65, 0x74, 0x63, 0x68, 0x05, 0x6c, 0x6f,
  0x63, 0x61, 0x6c, 0x00
];

// Support code to generate the hex-lists above from
// a hex-stream.
void formatHexStream(String hexStream) {
  var s = '';
  for (int i = 0; i < hexStream.length / 2; i++) {
    if (s.length != 0) s += ', ';
    s += '0x';
    var x = hexStream.substring(i * 2, i * 2 + 2);
    s += x;
    if (((i + 1) % 8) == 0) {
      s += ',';
      print(s);
      s = '';
    }
  }
  if (s.length != 0) print(s);
}

// Support code for generating the hex-lists above.
void hexDumpList(List package) {
  var s = '';
  for (int i = 0; i < package.length; i++) {
    if (s.length != 0) s += ', ';
    s += '0x';
    var x = package[i].toRadixString(16);
    if (x.length == 1) s += '0';
    s += x;
    if (((i + 1) % 8) == 0) {
      s += ',';
      print(s);
      s = '';
    }
  }
  if (s.length != 0) print(s);
}
