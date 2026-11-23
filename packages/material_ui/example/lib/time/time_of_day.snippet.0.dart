// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [TimeOfDay].

(TimeOfDay, TimeOfDay, TimeOfDay) createTimes() {
  // #region body
  TimeOfDay now = TimeOfDay.now();
  const TimeOfDay releaseTime = TimeOfDay(hour: 15, minute: 0); // 3:00pm
  TimeOfDay roomBooked = TimeOfDay.fromDateTime(
    DateTime.parse('2018-10-20 16:30:04Z'),
  ); // 4:30pm
  // #endregion body
  return (now, releaseTime, roomBooked);
}
