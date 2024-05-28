// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:devtools_app_shared/ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../shared_preferences_state_provider.dart';
import 'data_panel.dart';
import 'keys_panel.dart';

/// The main body of the shared preferences tool.
/// It contains the [KeysPanel] and the [DataPanel].
class SharedPreferencesBody extends StatelessWidget {
  /// Default constructor for [SharedPreferencesBody].
  const SharedPreferencesBody({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isWebPlatform = SharedPreferencesStateProvider.isWebPlatformOf(
      context,
    );

    if (isWebPlatform) {
      return const _WebUnavailableMessage();
    }

    final Axis splitAxis = SplitPane.axisFor(context, 0.85);

    return SplitPane(
      axis: splitAxis,
      initialFractions: const <double>[0.33, 0.67],
      children: const <Widget>[
        KeysPanel(),
        DataPanel(),
      ],
    );
  }
}

class _WebUnavailableMessage extends StatelessWidget {
  const _WebUnavailableMessage();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Center(
      child: Container(
        width: 400.0,
        padding: const EdgeInsets.all(largeSpacing),
        child: Text.rich(
          textAlign: TextAlign.center,
          TextSpan(
            children: <InlineSpan>[
              TextSpan(
                text: 'The shared preferences tool is not available for web '
                    'platforms yet. Once this ',
                style: theme.regularTextStyle,
              ),
              TextSpan(
                text: 'issue',
                style: theme.linkTextStyle,
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launchUrl(
                      Uri.parse(
                        'https://github.com/flutter/devtools/issues/7766',
                      ),
                    );
                  },
              ),
              TextSpan(
                text: ' is resolved, this tool will be updated to support web '
                    'platforms.',
                style: theme.regularTextStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
