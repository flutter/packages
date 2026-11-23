// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [SearchDelegate].

// #region body
class CustomSearchHintDelegate extends SearchDelegate<String> {
  CustomSearchHintDelegate({required String hintText})
    : super(
        searchFieldLabel: hintText,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.search,
      );

  @override
  Widget buildLeading(BuildContext context) => const Text('leading');

  @override
  PreferredSizeWidget buildBottom(BuildContext context) {
    return const PreferredSize(
      preferredSize: Size.fromHeight(56.0),
      child: Text('bottom'),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) => const Text('suggestions');

  @override
  Widget buildResults(BuildContext context) => const Text('results');

  @override
  List<Widget> buildActions(BuildContext context) => <Widget>[];
}
// #endregion body
