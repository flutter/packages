// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_unit_tests/null_fields.gen.dart';

void main() {
  test('test constructor with values', () {
    final NullFieldsSearchRequest request =
        NullFieldsSearchRequest(query: 'query', identifier: 1);

    final NullFieldsSearchReply reply = NullFieldsSearchReply(
      result: 'result',
      error: 'error',
      indices: <int>[1, 2, 3],
      request: request,
      type: NullFieldsSearchReplyType.success,
    );

    expect(reply.result, 'result');
    expect(reply.error, 'error');
    expect(reply.indices, <int>[1, 2, 3]);
    expect(reply.request!.query, 'query');
    expect(reply.type, NullFieldsSearchReplyType.success);
  });

  test('test request constructor with nulls', () {
    final NullFieldsSearchRequest request =
        NullFieldsSearchRequest(identifier: 1);

    expect(request.query, isNull);
  });

  test('test reply constructor with nulls', () {
    final NullFieldsSearchReply reply = NullFieldsSearchReply();

    expect(reply.result, isNull);
    expect(reply.error, isNull);
    expect(reply.indices, isNull);
    expect(reply.request, isNull);
    expect(reply.type, isNull);
  });

  test('test request decode with values', () {
    final NullFieldsSearchRequest request =
        NullFieldsSearchRequest.decode(<String, dynamic>{
      'query': 'query',
      'identifier': 1,
    });

    expect(request.query, 'query');
  });

  test('test request decode with null', () {
    final NullFieldsSearchRequest request =
        NullFieldsSearchRequest.decode(<String, dynamic>{
      'query': null,
      'identifier': 1,
    });

    expect(request.query, isNull);
  });

  test('test reply decode with values', () {
    final NullFieldsSearchReply reply =
        NullFieldsSearchReply.decode(<String, dynamic>{
      'result': 'result',
      'error': 'error',
      'indices': <int>[1, 2, 3],
      'request': <String, dynamic>{
        'query': 'query',
        'identifier': 1,
      },
      'type': NullFieldsSearchReplyType.success.index,
    });

    expect(reply.result, 'result');
    expect(reply.error, 'error');
    expect(reply.indices, <int>[1, 2, 3]);
    expect(reply.request!.query, 'query');
    expect(reply.type, NullFieldsSearchReplyType.success);
  });

  test('test reply decode with nulls', () {
    final NullFieldsSearchReply reply =
        NullFieldsSearchReply.decode(<String, dynamic>{
      'result': null,
      'error': null,
      'indices': null,
      'request': null,
      'type': null,
    });

    expect(reply.result, isNull);
    expect(reply.error, isNull);
    expect(reply.indices, isNull);
    expect(reply.request, isNull);
    expect(reply.type, isNull);
  });

  test('test request encode with values', () {
    final NullFieldsSearchRequest request =
        NullFieldsSearchRequest(query: 'query', identifier: 1);

    expect(request.encode(), <String, dynamic>{
      'query': 'query',
      'identifier': 1,
    });
  });

  test('test request encode with null', () {
    final NullFieldsSearchRequest request =
        NullFieldsSearchRequest(identifier: 1);

    expect(request.encode(), <String, dynamic>{
      'query': null,
      'identifier': 1,
    });
  });

  test('test reply encode with values', () {
    final NullFieldsSearchReply reply = NullFieldsSearchReply(
      result: 'result',
      error: 'error',
      indices: <int>[1, 2, 3],
      request: NullFieldsSearchRequest(query: 'query', identifier: 1),
      type: NullFieldsSearchReplyType.success,
    );

    expect(reply.encode(), <String, dynamic>{
      'result': 'result',
      'error': 'error',
      'indices': <int>[1, 2, 3],
      'request': <String, dynamic>{
        'query': 'query',
        'identifier': 1,
      },
      'type': NullFieldsSearchReplyType.success.index,
    });
  });

  test('test reply encode with nulls', () {
    final NullFieldsSearchReply reply = NullFieldsSearchReply();

    expect(reply.encode(), <String, dynamic>{
      'result': null,
      'error': null,
      'indices': null,
      'request': null,
      'type': null,
    });
  });
}
