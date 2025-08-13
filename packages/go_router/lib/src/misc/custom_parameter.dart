// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:meta/meta_meta.dart' show Target, TargetKind;

/// annotation to define a custom parameter decoder/encoder
/// this is useful when the is encoded/decoded in a non-standard way like base64Url
/// this must be used as an annotation on a field
/// ```dart
/// String fromBase64(String value) {
///   return const Utf8Decoder()
///     .convert(base64Url.decode(base64Url.normalize(value)));
/// }
/// String toBase64(String value) {
///   return base64Url.encode(const Utf8Encoder().convert(value));
/// }
/// @TypedGoRoute<JsonRoute>(path: 'json')
/// class JsonRoute extends GoRouteData with _$EncodedRoute {
///   @CustomParameterCodec(
///     encode: toBase64,
///     decode: fromBase64,
///   )
///   final String data;
///   JsonRoute(this.data);
/// }
/// ```
@Target(<TargetKind>{TargetKind.field})
final class CustomParameterCodec {
  /// create a custom parameter codec
  ///
  const CustomParameterCodec({
    required this.encode,
    required this.decode,
  });

  /// custom function to encode the field
  final String Function(String field) encode;

  /// custom function to decode the field
  final String Function(String field) decode;
}
