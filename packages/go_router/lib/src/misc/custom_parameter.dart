// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta_meta.dart';

/// annotation to define a custom parameter decoder/encoder
/// this is useful when the is encoded/decoded in a non-standard way like base64
/// this must be used as an annotation on a field
/// ```dart
/// String fromBase64(String value) {
///   return const Utf8Decoder().convert(base64.decode(value));
/// }
/// String toBase64(String value) {
///   return base64.encode(const Utf8Encoder().convert(value));
/// }
/// class MyRoute {
///   @CustomParameterCodec(
///     encode: toBase64,
///     decode: fromBase64,
///   )
///   final String data;
///   MyRoute(this.data);
/// }
/// ```
@Target(<TargetKind>{TargetKind.field})
class CustomParameterCodec {
  /// create a custom parameter codec
  ///
  const CustomParameterCodec({
    required this.encode,
    required this.decode,
  });

  /// custom function to encode the field
  final String Function(String json) encode;

  /// custom function to decode the field
  final String Function(String json) decode;
}
