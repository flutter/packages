// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [showTimePicker].

Future<TimeOfDay?> pickTime(BuildContext context) {
  // #region body
  Future<TimeOfDay?> selectedTime = showTimePicker(
    initialTime: TimeOfDay.now(),
    context: context,
  );
  // #endregion body
  return selectedTime;
}
