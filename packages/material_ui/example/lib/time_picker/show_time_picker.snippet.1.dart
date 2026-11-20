// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [showTimePicker].

Future<TimeOfDay?> pickTimeRTL(BuildContext context) {
  // #region body
  Future<TimeOfDay?> selectedTimeRTL = showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
    builder: (BuildContext context, Widget? child) {
      return Directionality(textDirection: TextDirection.rtl, child: child!);
    },
  );
  // #endregion body
  return selectedTimeRTL;
}
