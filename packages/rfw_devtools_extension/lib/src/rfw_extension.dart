// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:devtools_app_shared/ui.dart';
import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:flutter/material.dart';
import 'package:rfw_devtools_extension/src/controller.dart';
import 'package:rfw_devtools_extension/src/widgets/rfw_list.dart';
import 'package:rfw_devtools_extension/src/widgets/rfw_viewer.dart';

class RfwDevToolsExtension extends StatefulWidget {
  const RfwDevToolsExtension({super.key});

  @override
  State<RfwDevToolsExtension> createState() => _RfwDevToolsExtensionState();
}

class _RfwDevToolsExtensionState extends State<RfwDevToolsExtension> {
  late final RfwExtensionController extensionController;

  @override
  void initState() {
    super.initState();
    extensionController = RfwExtensionController()..init();
  }

  @override
  Widget build(BuildContext context) {
    return DevToolsExtension(
      child: _RfwInspector(extensionController: extensionController),
    );
  }
}

class _RfwInspector extends StatelessWidget {
  const _RfwInspector({required this.extensionController});

  final RfwExtensionController extensionController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AreaPaneHeader(
          title: Text('RFW Playground'),
          roundedTopBorder: false,
          includeLeftBorder: true,
          includeRightBorder: true,
          includeBottomBorder: false,
        ),
        Expanded(
          child: OutlineDecoration(
            child: Split(
              axis: Axis.horizontal,
              initialFractions: const [0.2, 0.8],
              children: [
                OutlineDecoration.onlyRight(
                  child: RfwList(extensionController: extensionController),
                ),
                OutlineDecoration.onlyLeft(
                  child: RfwViewer(extensionController: extensionController),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
