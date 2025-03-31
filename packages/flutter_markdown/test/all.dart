// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'blockquote_test.dart' as blockquote_test;
import 'custom_syntax_test.dart' as custome_syntax_test;
import 'emphasis_test.dart' as emphasis_test;
import 'footnote_test.dart' as footnote_test;
import 'header_test.dart' as header_test;
import 'horizontal_rule_test.dart' as horizontal_rule_test;
import 'html_test.dart' as html_test;
import 'image_test.dart' as image_test;
import 'line_break_test.dart' as line_break_test;
import 'link_test.dart' as link_test;
import 'list_test.dart' as list_test;
import 'scrollable_test.dart' as scrollable_test;
import 'selection_area_compatibility_test.dart' as selection_area_test;
import 'style_sheet_test.dart' as style_sheet_test;
import 'table_test.dart' as table_test;
import 'text_alignment_test.dart' as text_alignment_test;
import 'text_scaler_test.dart' as text_scaler;
import 'text_test.dart' as text_test;
import 'uri_test.dart' as uri_test;

void main() {
  blockquote_test.defineTests();
  custome_syntax_test.defineTests();
  emphasis_test.defineTests();
  footnote_test.defineTests();
  header_test.defineTests();
  horizontal_rule_test.defineTests();
  html_test.defineTests();
  image_test.defineTests();
  line_break_test.defineTests();
  link_test.defineTests();
  list_test.defineTests();
  scrollable_test.defineTests();
  selection_area_test.defineTests();
  style_sheet_test.defineTests();
  table_test.defineTests();
  text_test.defineTests();
  text_alignment_test.defineTests();
  text_scaler.defineTests();
  uri_test.defineTests();
}
