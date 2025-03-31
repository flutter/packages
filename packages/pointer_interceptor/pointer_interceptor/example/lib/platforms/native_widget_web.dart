// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

/// The html.Element that will be rendered underneath the flutter UI.
html.Element htmlElement = html.DivElement()
  ..style.width = '100%'
  ..style.height = '100%'
  ..style.backgroundColor = '#fabada'
  ..style.cursor = 'auto'
  ..id = 'background-html-view';

// See other examples commented out below...

// html.Element htmlElement = html.VideoElement()
//   ..style.width = '100%'
//   ..style.height = '100%'
//   ..style.cursor = 'auto'
//   ..style.backgroundColor = 'black'
//   ..id = 'background-html-view'
//   ..src = 'https://archive.org/download/BigBuckBunny_124/Content/big_buck_bunny_720p_surround.mp4'
//   ..poster = 'https://peach.blender.org/wp-content/uploads/title_anouncement.jpg?x11217'
//   ..controls = true;

// html.Element htmlElement = html.IFrameElement()
//       ..width = '100%'
//       ..height = '100%'
//       ..id = 'background-html-view'
//       ..src = 'https://www.youtube.com/embed/IyFZznAk69U'
//       ..style.border = 'none';

const String _htmlElementViewType = '_htmlElementViewType';

/// A widget representing an underlying html view
class NativeWidget extends StatelessWidget {
  /// Constructor
  const NativeWidget({super.key, required this.onClick});

  /// A function to run when the element is clicked
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    htmlElement.onClick.listen((_) {
      onClick();
    });

    ui_web.platformViewRegistry.registerViewFactory(
      _htmlElementViewType,
      (int viewId) => htmlElement,
    );

    return const HtmlElementView(
      viewType: _htmlElementViewType,
    );
  }
}
