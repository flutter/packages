// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/widgets.dart';

// ignore_for_file: public_member_api_docs

abstract class MarkdownDemoWidget extends Widget {
  const MarkdownDemoWidget({super.key});

  // The title property should be a short name to uniquely identify the example
  // demo. The title will be displayed at the top of the card in the home screen
  // to identify the demo and as the banner title on the demo screen.
  String get title;

  // The description property should be a short explanation to provide
  // additional information to clarify the actions performed by the demo. This
  // should be a terse explanation of no more than three sentences.
  String get description;

  // The data property is the sample Markdown source text data to be displayed
  // in the Formatted and Raw tabs of the demo screen. This data will be used by
  // the demo widget that implements MarkdownDemoWidget to format the Markdown
  // data to be displayed in the Formatted tab. The raw source text of data is
  // used by the Raw tab of the demo screen. The data can be as short or as long
  // as needed for demonstration purposes.
  Future<String> get data;

  // The notes property is a detailed explanation of the syntax, concepts,
  // comments, notes, or other additional information useful in explaining the
  // demo. The notes are displayed in the Notes tab of the demo screen. Notes
  // supports Markdown data to allow for rich text formatting.
  Future<String> get notes;
}
