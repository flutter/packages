// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:vector_graphics_codec/vector_graphics_codec.dart';

final Float64List identity = Float64List.fromList(<double>[
  1,
  0,
  0,
  0,
  0,
  1,
  0,
  0,
  0,
  0,
  1,
  0,
  0,
  0,
  0,
  1,
]);

void main() {
  const codec = VectorGraphicsCodec();
  test('metadata reads dimensions and ordered filters without a rendering listener', () {
    final buffer = VectorGraphicsBuffer();
    codec.writeSize(buffer, 24, 48);
    final filters = <VectorFilter>[
      VectorFilter('filter', const <String, String>{'id': 'outer'}),
      VectorFilter('filter', const <String, String>{'id': 'inner'}),
    ];
    for (final filter in filters) {
      codec.writeBeginFilter(buffer, filter, identity, 24, 48);
    }
    codec.writeEndFilter(buffer);
    codec.writeEndFilter(buffer);
    final VectorGraphicsMetadata metadata = codec.readMetadata(buffer.done());
    expect((metadata.width, metadata.height), (24, 48));
    expect(metadata.filters, filters);
    expect(() => metadata.filters.clear(), throwsUnsupportedError);
    final plain = VectorGraphicsBuffer();
    codec.writeSize(plain, 12, 16);
    expect(codec.readMetadata(plain.done()).filters, isEmpty);
    expect(() => codec.readMetadata(ByteData(0)), throwsStateError);
  });
  test('geometry metadata survives both metadata and rendering passes', () {
    final buffer = VectorGraphicsBuffer();
    codec.writeSize(buffer, 128, 128);
    codec.writeBeginFilter(
      buffer,
      VectorFilter('filter', const <String, String>{'id': 'f'}),
      identity,
      128,
      128,
    );
    codec.writePathGeometry(buffer, 7);
    codec.writeEndFilter(buffer);
    final ByteData bytes = buffer.done();
    expect(codec.readMetadata(bytes).filters.single.attributes['id'], 'f');
    final listener = _FilterListener();
    codec.decode(bytes, listener);
    expect(listener.events, <String>['begin:f:128.0:128.0', 'geometry:7', 'end']);
  });
  test('geometry outside a filter fails even without a listener', () {
    final buffer = VectorGraphicsBuffer();
    codec.writeSize(buffer, 128, 128);
    codec.writePathGeometry(buffer, 0);
    expect(() => codec.readMetadata(buffer.done()), throwsFormatException);
  });
  test('description round trip preserves parameters, names and child order', () {
    final filter = VectorFilter(
      'filter',
      const <String, String>{'id': '雪', 'filterUnits': 'objectBoundingBox'},
      <VectorFilter>[
        VectorFilter(
          'feFuture',
          const <String, String>{'in': 'SourceAlpha', 'result': '雪'},
          <VectorFilter>[
            VectorFilter('feParameter', const <String, String>{'values': '1 0 -2'}),
          ],
        ),
      ],
    );
    expect(
      VectorFilter.fromJson(
        jsonDecode(jsonEncode(filter.toJson())) as Map<String, dynamic>,
      ).toJson(),
      filter.toJson(),
    );
  });
  test('equality is independent of attribute insertion order', () {
    final a = VectorFilter('filter', const <String, String>{'id': 'f', 'x': '2'});
    final b = VectorFilter('filter', const <String, String>{'x': '2', 'id': 'f'});
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a, isNot(VectorFilter('filter', const <String, String>{'id': 'g', 'x': '2'})));
  });
  test('description defensively copies collections', () {
    final attributes = <String, String>{'id': 'f'};
    final children = <VectorFilter>[];
    final filter = VectorFilter('filter', attributes, children);
    attributes['id'] = 'changed';
    children.add(VectorFilter('bad', const <String, String>{}));
    expect(filter.attributes['id'], 'f');
    expect(filter.children, isEmpty);
    expect(() => filter.attributes['id'] = 'bad', throwsUnsupportedError);
  });
  for (final json in <Map<String, Object?>>[
    <String, Object?>{},
    <String, Object?>{'name': 1, 'attributes': <String, String>{}, 'children': <Object>[]},
    <String, Object?>{'name': 'filter', 'attributes': <String, String>{}, 'children': 'bad'},
  ]) {
    test('malformed descriptions are rejected: $json', () {
      expect(() => VectorFilter.fromJson(json), throwsFormatException);
    });
  }
  test('filter commands preserve matrix and viewport through codec', () {
    final buffer = VectorGraphicsBuffer();
    codec.writeSize(buffer, 128, 128);
    codec.writeBeginFilter(
      buffer,
      VectorFilter('filter', const <String, String>{'id': 'f'}),
      identity,
      128,
      64,
    );
    codec.writeEndFilter(buffer);
    final listener = _FilterListener();
    expect(codec.decode(buffer.done(), listener).complete, isTrue);
    expect(listener.events, <String>['begin:f:128.0:64.0', 'end']);
    expect(listener.transform, identity);
  });
  test('a missing end command is rejected without a listener', () {
    final buffer = VectorGraphicsBuffer();
    codec.writeSize(buffer, 128, 128);
    codec.writeBeginFilter(
      buffer,
      VectorFilter('filter', const <String, String>{}),
      identity,
      128,
      128,
    );
    expect(() => codec.decode(buffer.done(), null), throwsFormatException);
  });
  test('an unmatched end command is rejected without a listener', () {
    final buffer = VectorGraphicsBuffer();
    codec.writeSize(buffer, 128, 128);
    codec.writeEndFilter(buffer);
    expect(() => codec.decode(buffer.done(), null), throwsFormatException);
  });
  test('filter instructions cannot masquerade as version 1', () {
    final buffer = VectorGraphicsBuffer();
    codec.writeSize(buffer, 128, 128);
    codec.writeBeginFilter(
      buffer,
      VectorFilter('filter', const <String, String>{}),
      identity,
      128,
      128,
    );
    codec.writeEndFilter(buffer);
    final ByteData data = buffer.done()..setUint8(4, 1);
    expect(() => codec.decode(data, null), throwsFormatException);
  });
  for (final matrix in <Float64List>[
    Float64List(0),
    Float64List(15),
    Float64List.fromList(identity)..[0] = double.nan,
  ]) {
    test('invalid matrix cannot be encoded: ${matrix.length}/${matrix.firstOrNull}', () {
      final buffer = VectorGraphicsBuffer();
      codec.writeSize(buffer, 128, 128);
      expect(
        () => codec.writeBeginFilter(
          buffer,
          VectorFilter('filter', const <String, String>{}),
          matrix,
          128,
          128,
        ),
        throwsArgumentError,
      );
    });
  }
}

class _FilterListener extends VectorGraphicsCodecListener {
  final List<String> events = <String>[];
  Float64List? transform;
  @override
  void onSize(double width, double height) {}
  @override
  void onBeginFilter(VectorFilter filter, Float64List matrix, double width, double height) {
    events.add('begin:${filter.attributes['id']}:$width:$height');
    transform = matrix;
  }

  @override
  void onEndFilter() => events.add('end');
  @override
  void onPathGeometry(int pathId) => events.add('geometry:$pathId');
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
