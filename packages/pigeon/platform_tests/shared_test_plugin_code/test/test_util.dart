// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:mockito/mockito.dart';

void echoOneArgument(
  BinaryMessenger mockMessenger,
  String channel,
  MessageCodec<Object?> codec,
) {
  when(mockMessenger.send(channel, any)).thenAnswer((
    Invocation realInvocation,
  ) async {
    final Object input = codec.decodeMessage(
      realInvocation.positionalArguments[1] as ByteData?,
    )!;
    final args = input as List<Object?>;
    return codec.encodeMessage(<Object>[args[0]!]);
  });
}
