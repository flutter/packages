// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_ui_examples/time/time_of_day.snippet.0.dart'
    as example;

void main() {
  test('TimeOfDay constructors create valid 24-hour times', () {
    final (TimeOfDay now, TimeOfDay releaseTime, TimeOfDay roomBooked) = example
        .createTimes();

    expect(now.hour, inInclusiveRange(0, 23));
    expect(now.minute, inInclusiveRange(0, 59));
    expect(releaseTime, const TimeOfDay(hour: 15, minute: 0));
    expect(roomBooked, const TimeOfDay(hour: 16, minute: 30));

    const DefaultMaterialLocalizations localizations =
        DefaultMaterialLocalizations();
    expect(localizations.formatTimeOfDay(releaseTime), '3:00 PM');
    expect(localizations.formatTimeOfDay(roomBooked), '4:30 PM');
  });
}
