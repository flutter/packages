// Copyright (c) 2015, the Fletch project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE.md file.

import 'dart:io';

import 'package:expect/expect.dart';
import 'package:mdns/src/constants.dart' show RRType;
import 'package:mdns/src/lookup_resolver.dart';
import 'package:mdns/src/packet.dart';

main() async {
  await testTimeout();
  await testResult();
  await testResult2();
  await testResult3();
}

ResourceRecord ip4Result(String name, InternetAddress address) {
  int validUntil = new DateTime.now().millisecondsSinceEpoch + 2000;
  return new ResourceRecord(RRType.A, name, address, validUntil);
}

testTimeout() async {
  var shortTimeout = new Duration(milliseconds: 1);
  var resolver = new LookupResolver();
  var result = resolver.addPendingRequest(RRType.A, 'xxx', shortTimeout);
  Expect.isTrue(await result.isEmpty);
}

// One pending request and one response.
testResult() async {
  var noTimeout = new Duration(days: 1);
  var resolver = new LookupResolver();
  var futureResult = resolver.addPendingRequest(RRType.A, 'xxx', noTimeout);
  var response = ip4Result('xxx', new InternetAddress('1.2.3.4'));
  resolver.handleResponse([response]);
  var result = await futureResult.first;
  Expect.equals('1.2.3.4', result.address.address);
  resolver.clearPendingRequests();
}

testResult2() async {
  var noTimeout = new Duration(days: 1);
  var resolver = new LookupResolver();
  var futureResult1 = resolver.addPendingRequest(RRType.A, 'xxx', noTimeout);
  var futureResult2 = resolver.addPendingRequest(RRType.A, 'yyy', noTimeout);
  var response1 = ip4Result('xxx', new InternetAddress('1.2.3.4'));
  var response2 = ip4Result('yyy', new InternetAddress('2.3.4.5'));
  resolver.handleResponse([response2, response1]);
  var result1 = await futureResult1.first;
  var result2 = await futureResult2.first;
  Expect.equals('1.2.3.4', result1.address.address);
  Expect.equals('2.3.4.5', result2.address.address);
  resolver.clearPendingRequests();
}

testResult3() async {
  var noTimeout = new Duration(days: 1);
  var resolver = new LookupResolver();
  var response0 = ip4Result('zzz', new InternetAddress('2.3.4.5'));
  resolver.handleResponse([response0]);
  var futureResult1 = resolver.addPendingRequest(RRType.A, 'xxx', noTimeout);
  resolver.handleResponse([response0]);
  var futureResult2 = resolver.addPendingRequest(RRType.A, 'yyy', noTimeout);
  resolver.handleResponse([response0]);
  var response1 = ip4Result('xxx', new InternetAddress('1.2.3.4'));
  resolver.handleResponse([response0]);
  var response2 = ip4Result('yyy', new InternetAddress('2.3.4.5'));
  resolver.handleResponse([response0]);
  resolver.handleResponse([response2, response1]);
  resolver.handleResponse([response0]);
  var result1 = await futureResult1.first;
  var result2 = await futureResult2.first;
  Expect.equals('1.2.3.4', result1.address.address);
  Expect.equals('2.3.4.5', result2.address.address);
  resolver.clearPendingRequests();
}
