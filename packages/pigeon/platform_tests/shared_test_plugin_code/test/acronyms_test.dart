// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_test_plugin_code/generated.dart';

import 'null_safe_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('echoAcronyms sends correct message', () async {
    final BinaryMessenger mockMessenger = MockBinaryMessenger();
    final completer = Completer<ByteData?>();

    final acronyms = AcronymsAndTestCase(
      httpResponse: 'HTTP_RESPONSE',
      jsonParser: 'JSON_PARSER',
      xmlNode: 'XML_NODE',
    );

    completer.complete(
      HostIntegrationCoreApi.pigeonChannelCodec.encodeMessage(<Object>[
        acronyms,
      ]),
    );
    final Future<ByteData?> sendResult = completer.future;

    when(
      mockMessenger.send(
        'dev.flutter.pigeon.pigeon_integration_tests.HostIntegrationCoreApi.echoAcronyms',
        any,
      ),
    ).thenAnswer((Invocation realInvocation) => sendResult);

    final api = HostIntegrationCoreApi(binaryMessenger: mockMessenger);
    final AcronymsAndTestCase received = await api.echoAcronyms(acronyms);

    expect(received, isNotNull);
    expect(received.httpResponse, acronyms.httpResponse);
    expect(received.jsonParser, acronyms.jsonParser);
    expect(received.xmlNode, acronyms.xmlNode);
  });

  test('hostHTTPResponse sends correct message', () async {
    final BinaryMessenger mockMessenger = MockBinaryMessenger();
    final completer = Completer<ByteData?>();

    final acronyms = AcronymsAndTestCase(
      httpResponse: 'HTTP_RESPONSE',
      jsonParser: 'JSON_PARSER',
      xmlNode: 'XML_NODE',
      acronymsEnum: AcronymsEnum.HTTPResponse,
    );

    completer.complete(
      HostIntegrationCoreApi.pigeonChannelCodec.encodeMessage(<Object>[
        acronyms,
      ]),
    );
    final Future<ByteData?> sendResult = completer.future;

    when(
      mockMessenger.send(
        'dev.flutter.pigeon.pigeon_integration_tests.HostIntegrationCoreApi.hostHTTPResponse',
        any,
      ),
    ).thenAnswer((Invocation realInvocation) => sendResult);

    final api = HostIntegrationCoreApi(binaryMessenger: mockMessenger);
    final AcronymsAndTestCase received = await api.hostHTTPResponse(acronyms);

    expect(received, isNotNull);
    expect(received.httpResponse, acronyms.httpResponse);
    expect(received.acronymsEnum, acronyms.acronymsEnum);
  });

  test('sendJSONParser sends correct message', () async {
    final BinaryMessenger mockMessenger = MockBinaryMessenger();
    final completer = Completer<ByteData?>();

    final acronyms = AcronymsAndTestCase(
      httpResponse: 'HTTP_RESPONSE',
      jsonParser: 'JSON_PARSER',
      xmlNode: 'XML_NODE',
      acronymsEnum: AcronymsEnum.JSONParser,
    );

    completer.complete(
      HostIntegrationCoreApi.pigeonChannelCodec.encodeMessage(<Object>[
        acronyms,
      ]),
    );
    final Future<ByteData?> sendResult = completer.future;

    when(
      mockMessenger.send(
        'dev.flutter.pigeon.pigeon_integration_tests.HostIntegrationCoreApi.sendJSONParser',
        any,
      ),
    ).thenAnswer((Invocation realInvocation) => sendResult);

    final api = HostIntegrationCoreApi(binaryMessenger: mockMessenger);
    final AcronymsAndTestCase received = await api.sendJSONParser(acronyms);

    expect(received, isNotNull);
    expect(received.jsonParser, acronyms.jsonParser);
    expect(received.acronymsEnum, acronyms.acronymsEnum);
  });
}
