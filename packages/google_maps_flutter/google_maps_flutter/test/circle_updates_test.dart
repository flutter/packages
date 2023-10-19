// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

import 'fake_google_maps_flutter_platform.dart';

Widget _mapWithCircles(Set<Circle> circles) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: GoogleMap(
      initialCameraPosition: const CameraPosition(target: LatLng(10.0, 15.0)),
      circles: circles,
    ),
  );
}

void main() {
  late FakeGoogleMapsFlutterPlatform platform;

  setUp(() {
    platform = FakeGoogleMapsFlutterPlatform();
    GoogleMapsFlutterPlatform.instance = platform;
  });

  testWidgets('Initializing a circle', (WidgetTester tester) async {
    const Circle c1 = Circle(circleId: CircleId('circle_1'));
    await tester.pumpWidget(_mapWithCircles(<Circle>{c1}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.circleUpdates.last.circlesToAdd.length, 1);

    final Circle initializedCircle = map.circleUpdates.last.circlesToAdd.first;
    expect(initializedCircle, equals(c1));
    expect(map.circleUpdates.last.circleIdsToRemove.isEmpty, true);
    expect(map.circleUpdates.last.circlesToChange.isEmpty, true);
  });

  testWidgets('Adding a circle', (WidgetTester tester) async {
    const Circle c1 = Circle(circleId: CircleId('circle_1'));
    const Circle c2 = Circle(circleId: CircleId('circle_2'));

    await tester.pumpWidget(_mapWithCircles(<Circle>{c1}));
    await tester.pumpWidget(_mapWithCircles(<Circle>{c1, c2}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.circleUpdates.last.circlesToAdd.length, 1);

    final Circle addedCircle = map.circleUpdates.last.circlesToAdd.first;
    expect(addedCircle, equals(c2));

    expect(map.circleUpdates.last.circleIdsToRemove.isEmpty, true);

    expect(map.circleUpdates.last.circlesToChange.isEmpty, true);
  });

  testWidgets('Removing a circle', (WidgetTester tester) async {
    const Circle c1 = Circle(circleId: CircleId('circle_1'));

    await tester.pumpWidget(_mapWithCircles(<Circle>{c1}));
    await tester.pumpWidget(_mapWithCircles(<Circle>{}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.circleUpdates.last.circleIdsToRemove.length, 1);
    expect(map.circleUpdates.last.circleIdsToRemove.first, equals(c1.circleId));

    expect(map.circleUpdates.last.circlesToChange.isEmpty, true);
    expect(map.circleUpdates.last.circlesToAdd.isEmpty, true);
  });

  testWidgets('Updating a circle', (WidgetTester tester) async {
    const Circle c1 = Circle(circleId: CircleId('circle_1'));
    const Circle c2 = Circle(circleId: CircleId('circle_1'), radius: 10);

    await tester.pumpWidget(_mapWithCircles(<Circle>{c1}));
    await tester.pumpWidget(_mapWithCircles(<Circle>{c2}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.circleUpdates.last.circlesToChange.length, 1);
    expect(map.circleUpdates.last.circlesToChange.first, equals(c2));

    expect(map.circleUpdates.last.circleIdsToRemove.isEmpty, true);
    expect(map.circleUpdates.last.circlesToAdd.isEmpty, true);
  });

  testWidgets('Updating a circle', (WidgetTester tester) async {
    const Circle c1 = Circle(circleId: CircleId('circle_1'));
    const Circle c2 = Circle(circleId: CircleId('circle_1'), radius: 10);

    await tester.pumpWidget(_mapWithCircles(<Circle>{c1}));
    await tester.pumpWidget(_mapWithCircles(<Circle>{c2}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;
    expect(map.circleUpdates.last.circlesToChange.length, 1);

    final Circle update = map.circleUpdates.last.circlesToChange.first;
    expect(update, equals(c2));
    expect(update.radius, 10);
  });

  testWidgets('Multi Update', (WidgetTester tester) async {
    Circle c1 = const Circle(circleId: CircleId('circle_1'));
    Circle c2 = const Circle(circleId: CircleId('circle_2'));
    final Set<Circle> prev = <Circle>{c1, c2};
    c1 = const Circle(circleId: CircleId('circle_1'), visible: false);
    c2 = const Circle(circleId: CircleId('circle_2'), radius: 10);
    final Set<Circle> cur = <Circle>{c1, c2};

    await tester.pumpWidget(_mapWithCircles(prev));
    await tester.pumpWidget(_mapWithCircles(cur));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.circleUpdates.last.circlesToChange, cur);
    expect(map.circleUpdates.last.circleIdsToRemove.isEmpty, true);
    expect(map.circleUpdates.last.circlesToAdd.isEmpty, true);
  });

  testWidgets('Multi Update', (WidgetTester tester) async {
    Circle c2 = const Circle(circleId: CircleId('circle_2'));
    const Circle c3 = Circle(circleId: CircleId('circle_3'));
    final Set<Circle> prev = <Circle>{c2, c3};

    // c1 is added, c2 is updated, c3 is removed.
    const Circle c1 = Circle(circleId: CircleId('circle_1'));
    c2 = const Circle(circleId: CircleId('circle_2'), radius: 10);
    final Set<Circle> cur = <Circle>{c1, c2};

    await tester.pumpWidget(_mapWithCircles(prev));
    await tester.pumpWidget(_mapWithCircles(cur));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.circleUpdates.last.circlesToChange.length, 1);
    expect(map.circleUpdates.last.circlesToAdd.length, 1);
    expect(map.circleUpdates.last.circleIdsToRemove.length, 1);

    expect(map.circleUpdates.last.circlesToChange.first, equals(c2));
    expect(map.circleUpdates.last.circlesToAdd.first, equals(c1));
    expect(map.circleUpdates.last.circleIdsToRemove.first, equals(c3.circleId));
  });

  testWidgets('Partial Update', (WidgetTester tester) async {
    const Circle c1 = Circle(circleId: CircleId('circle_1'));
    const Circle c2 = Circle(circleId: CircleId('circle_2'));
    Circle c3 = const Circle(circleId: CircleId('circle_3'));
    final Set<Circle> prev = <Circle>{c1, c2, c3};
    c3 = const Circle(circleId: CircleId('circle_3'), radius: 10);
    final Set<Circle> cur = <Circle>{c1, c2, c3};

    await tester.pumpWidget(_mapWithCircles(prev));
    await tester.pumpWidget(_mapWithCircles(cur));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.circleUpdates.last.circlesToChange, <Circle>{c3});
    expect(map.circleUpdates.last.circleIdsToRemove.isEmpty, true);
    expect(map.circleUpdates.last.circlesToAdd.isEmpty, true);
  });

  testWidgets('Update non platform related attr', (WidgetTester tester) async {
    Circle c1 = const Circle(circleId: CircleId('circle_1'));
    final Set<Circle> prev = <Circle>{c1};
    c1 = Circle(circleId: const CircleId('circle_1'), onTap: () {});
    final Set<Circle> cur = <Circle>{c1};

    await tester.pumpWidget(_mapWithCircles(prev));
    await tester.pumpWidget(_mapWithCircles(cur));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.circleUpdates.last.circlesToChange.isEmpty, true);
    expect(map.circleUpdates.last.circleIdsToRemove.isEmpty, true);
    expect(map.circleUpdates.last.circlesToAdd.isEmpty, true);
  });

  testWidgets('multi-update with delays', (WidgetTester tester) async {
    platform.simulatePlatformDelay = true;

    const Circle c1 = Circle(circleId: CircleId('circle_1'));
    const Circle c2 = Circle(circleId: CircleId('circle_2'));
    const Circle c3 = Circle(circleId: CircleId('circle_3'), radius: 1);
    const Circle c3updated = Circle(circleId: CircleId('circle_3'), radius: 10);

    // First remove one and add another, then update the new one.
    await tester.pumpWidget(_mapWithCircles(<Circle>{c1, c2}));
    await tester.pumpWidget(_mapWithCircles(<Circle>{c1, c3}));
    await tester.pumpWidget(_mapWithCircles(<Circle>{c1, c3updated}));

    final PlatformMapStateRecorder map = platform.lastCreatedMap;

    expect(map.circleUpdates.length, 3);

    expect(map.circleUpdates[0].circlesToChange.isEmpty, true);
    expect(map.circleUpdates[0].circlesToAdd, <Circle>{c1, c2});
    expect(map.circleUpdates[0].circleIdsToRemove.isEmpty, true);

    expect(map.circleUpdates[1].circlesToChange.isEmpty, true);
    expect(map.circleUpdates[1].circlesToAdd, <Circle>{c3});
    expect(map.circleUpdates[1].circleIdsToRemove, <CircleId>{c2.circleId});

    expect(map.circleUpdates[2].circlesToChange, <Circle>{c3updated});
    expect(map.circleUpdates[2].circlesToAdd.isEmpty, true);
    expect(map.circleUpdates[2].circleIdsToRemove.isEmpty, true);

    await tester.pumpAndSettle();
  });
}
