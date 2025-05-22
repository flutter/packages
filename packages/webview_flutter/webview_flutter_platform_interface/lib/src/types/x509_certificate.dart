// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

/// Represents an X.509 certificate.
@immutable
class X509Certificate {
  /// Creates an [X509Certificate].
  const X509Certificate({this.data});

  /// A DER representation of the certificate object.
  final Uint8List? data;
}
