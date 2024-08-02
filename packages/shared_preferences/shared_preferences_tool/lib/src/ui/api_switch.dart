// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:devtools_app_shared/ui.dart';
import 'package:flutter/material.dart';

import '../shared_preferences_state_provider.dart';

/// A switch to toggle between the legacy and async APIs.
class ApiSwitch extends StatelessWidget {
  /// Default constructor for [ApiSwitch].
  const ApiSwitch({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final bool legacyApi = SharedPreferencesStateProvider.legacyApiOf(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: denseSpacing),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Theme.of(context).focusColor),
        ),
      ),
      child: Center(
        child: DevToolsToggleButtonGroup(
          selectedStates: <bool>[legacyApi, !legacyApi],
          onPressed: (int index) {
            context.sharedPreferencesStateNotifier
                .selectApi(legacyApi: index == 0);
          },
          children: const <Widget>[
            Padding(
              padding: EdgeInsets.all(densePadding),
              child: Text('Legacy API'),
            ),
            Padding(
              padding: EdgeInsets.all(densePadding),
              child: Text('Async API'),
            ),
          ],
        ),
      ),
    );
  }
}
