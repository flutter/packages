// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [showTimePicker].

Future<TimeOfDay?> pickTime24Hour(BuildContext context) {
  // #region body
  Future<TimeOfDay?> selectedTime24Hour = showTimePicker(
    context: context,
    initialTime: const TimeOfDay(hour: 10, minute: 47),
    builder: (BuildContext context, Widget? child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      );
    },
  );
  // #endregion body
  return selectedTime24Hour;
}
