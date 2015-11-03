// Copyright (c) 2015, the Fletch project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE.md file.

import 'dart:io';

import 'package:expect/expect.dart';
import 'package:mdns/src/packet.dart';
import 'package:mdns/src/lookup_resolver.dart';

main() async {
  await testTimeout();
  await testResult();
  await testResult2();
  await testResult3();
}

testTimeout() async {
  var shortTimeout = new Duration(milliseconds: 1);
  var resolver = new LookupResolver();
  var result = await resolver.addPendingRequest('xxx', shortTimeout);
  Expect.isNull(result);
}

// One pending request and one response.
testResult() async {
  var noTimeout = new Duration(days: 1);
  var resolver = new LookupResolver();
  var futureResult = resolver.addPendingRequest('xxx', noTimeout);
  var response = new DecodeResult('xxx', new InternetAddress('1.2.3.4'));
  resolver.handleResponse([response]);
  var result = await futureResult;
  Expect.equals('1.2.3.4', result.address);
}

testResult2() async {
  var noTimeout = new Duration(days: 1);
  var resolver = new LookupResolver();
  var futureResult1 = resolver.addPendingRequest('xxx', noTimeout);
  var futureResult2 = resolver.addPendingRequest('yyy', noTimeout);
  var response1 = new DecodeResult('xxx', new InternetAddress('1.2.3.4'));
  var response2 = new DecodeResult('yyy', new InternetAddress('2.3.4.5'));
  resolver.handleResponse([response2, response1]);
  var result1 = await futureResult1;
  var result2 = await futureResult2;
  Expect.equals('1.2.3.4', result1.address);
  Expect.equals('2.3.4.5', result2.address);
}

testResult3() async {
  var noTimeout = new Duration(days: 1);
  var resolver = new LookupResolver();
  var response0 = new DecodeResult('zzz', new InternetAddress('2.3.4.5'));
  resolver.handleResponse([response0]);
  var futureResult1 = resolver.addPendingRequest('xxx', noTimeout);
  resolver.handleResponse([response0]);
  var futureResult2 = resolver.addPendingRequest('yyy', noTimeout);
  resolver.handleResponse([response0]);
  var response1 = new DecodeResult('xxx', new InternetAddress('1.2.3.4'));
  resolver.handleResponse([response0]);
  var response2 = new DecodeResult('yyy', new InternetAddress('2.3.4.5'));
  resolver.handleResponse([response0]);
  resolver.handleResponse([response2, response1]);
  resolver.handleResponse([response0]);
  var result1 = await futureResult1;
  var result2 = await futureResult2;
  Expect.equals('1.2.3.4', result1.address);
  Expect.equals('2.3.4.5', result2.address);
}
