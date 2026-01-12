// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This file exists solely to host compiled excerpts for README.md, and is not
// intended for use as an actual example application.

// ignore_for_file: avoid_print

import 'dart:typed_data';
import 'package:standard_message_codec/standard_message_codec.dart';

// #docregion Encoding
void main() {
  final ByteData? data = const StandardMessageCodec().encodeMessage(
    <Object, Object>{'foo': true, 3: 'fizz'},
  );
  print('The encoded message is $data');
}

// #enddocregion Encoding
