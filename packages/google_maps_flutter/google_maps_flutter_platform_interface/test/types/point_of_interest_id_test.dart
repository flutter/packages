// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

void main() {
  test('PointOfInterestId equality', () {
    const id1 = PointOfInterestId('place-123');
    const id2 = PointOfInterestId('place-123');
    const id3 = PointOfInterestId('place-456');

    expect(id1, equals(id2));
    expect(id1, isNot(equals(id3)));
    expect(id1.hashCode, equals(id2.hashCode));
  });

  test('PointOfInterestId toString', () {
    const id = PointOfInterestId('place-123');
    expect(id.toString(), contains('place-123'));
  });
}
