// Copyright 2013 The Flutter Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// #region body
import 'package:material_ui/material_ui.dart';

/// Flutter code sample for [SearchAnchor] with [SearchAnchor.enableTapHandling].

void main() => runApp(const SearchAnchorCustomSearchBarApp());

class SearchAnchorCustomSearchBarApp extends StatefulWidget {
  const SearchAnchorCustomSearchBarApp({super.key});

  @override
  State<SearchAnchorCustomSearchBarApp> createState() =>
      _SearchAnchorCustomSearchBarAppState();
}

class _SearchAnchorCustomSearchBarAppState
    extends State<SearchAnchorCustomSearchBarApp> {
  String? selectedItem;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Custom Search Bar Anchor Sample')),
        body: Align(
          alignment: Alignment.topCenter,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 16),
              SearchAnchor(
                // Set to false because SearchBar handles its own tap events.
                // This prevents duplicate gesture recognizers and duplicate
                // tap semantics actions.
                enableTapHandling: false,
                builder: (BuildContext context, SearchController controller) {
                  return SearchBar(
                    controller: controller,
                    hintText: 'Search items...',
                    onTap: () {
                      controller.openView();
                    },
                    onChanged: (String value) {
                      controller.openView();
                    },
                    leading: const Icon(Icons.search),
                  );
                },
                suggestionsBuilder:
                    (BuildContext context, SearchController controller) {
                      return List<ListTile>.generate(5, (int index) {
                        final String item = 'Item $index';
                        return ListTile(
                          title: Text(item),
                          onTap: () {
                            setState(() {
                              selectedItem = item;
                              controller.closeView(item);
                            });
                          },
                        );
                      });
                    },
              ),
              const SizedBox(height: 16),
              if (selectedItem == null)
                const Text('No item selected')
              else
                Text('Selected item: $selectedItem'),
            ],
          ),
        ),
      ),
    );
  }
}
// #endregion body
