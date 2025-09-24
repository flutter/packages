// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';

import 'package:go_router/go_router.dart';

String fromBase64(String value) {
  return const Utf8Decoder().convert(
    base64Url.decode(base64Url.normalize(value)),
  );
}

String toBase64(String value) {
  return base64Url.encode(const Utf8Encoder().convert(value));
}

mixin $CustomParameterRoute {}

@TypedGoRoute<CustomParameterRoute>(path: '/default-value-route')
class CustomParameterRoute extends GoRouteData with $CustomParameterRoute {
  CustomParameterRoute({required this.param});

  @CustomParameterCodec(encode: toBase64, decode: fromBase64)
  final int param;
}

mixin $CustomParameterComplexRoute {}

@TypedGoRoute<CustomParameterComplexRoute>(path: '/:id/')
class CustomParameterComplexRoute extends GoRouteData
    with $CustomParameterComplexRoute {
  CustomParameterComplexRoute({
    required this.id,
    this.dir = '',
    this.list = const <Uri>[],
    required this.enumTest,
  });

  @CustomParameterCodec(encode: toBase64, decode: fromBase64)
  final int id;

  @CustomParameterCodec(encode: toBase64, decode: fromBase64)
  final String dir;
  @CustomParameterCodec(encode: toBase64, decode: fromBase64)
  final List<Uri> list;
  @CustomParameterCodec(encode: toBase64, decode: fromBase64)
  final EnumTest enumTest;
}

enum EnumTest {
  a(1),
  b(3),
  c(5);

  const EnumTest(this.x);
  final int x;
}
