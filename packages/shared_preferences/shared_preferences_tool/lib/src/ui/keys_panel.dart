// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:devtools_app_shared/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../async_state.dart';
import '../shared_preferences_state.dart';
import '../shared_preferences_state_notifier.dart';
import '../shared_preferences_state_notifier_provider.dart';
import 'error_panel.dart';

/// A panel that displays the keys stored in shared preferences.
class KeysPanel extends StatefulWidget {
  /// Default constructor for [KeysPanel].
  const KeysPanel({super.key});

  @override
  State<KeysPanel> createState() => _KeysPanelState();
}

class _KeysPanelState extends State<KeysPanel> {
  bool searching = false;
  final FocusNode searchFocusNode = FocusNode();

  @override
  void dispose() {
    searchFocusNode.dispose();
    super.dispose();
  }

  void _startSearching() {
    setState(() {
      searching = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final SharedPreferencesStateNotifier notifier =
        SharedPreferencesStateNotifierProvider.of(context);

    void stopSearching() {
      setState(() {
        searching = false;
      });
      notifier.filter('');
    }

    return RoundedOutlinedBorder(
      clip: true,
      child: Column(
        children: <Widget>[
          AreaPaneHeader(
            roundedTopBorder: false,
            includeTopBorder: false,
            tall: true,
            title: Row(
              children: <Widget>[
                Text(
                  'Stored Keys',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (searching) ...<Widget>[
                  const SizedBox(
                    width: denseSpacing,
                  ),
                  Expanded(
                    child: KeyboardListener(
                      focusNode: searchFocusNode,
                      onKeyEvent: (KeyEvent value) {
                        if (value.logicalKey == LogicalKeyboardKey.escape) {
                          stopSearching();
                        }
                      },
                      child: TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: densePadding,
                          ),
                          hintText: 'Search',
                          border: const OutlineInputBorder(),
                          suffix: Tooltip(
                            message: 'Stop searching',
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                size: 16,
                              ),
                              onPressed: stopSearching,
                            ),
                          ),
                        ),
                        onChanged: notifier.filter,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: denseSpacing,
                  ),
                ] else ...<Widget>[
                  const Spacer(),
                  Tooltip(
                    message: 'Search',
                    child: IconButton(
                      icon: const Icon(
                        Icons.search,
                        size: 16,
                      ),
                      onPressed: _startSearching,
                    ),
                  ),
                ],
                Tooltip(
                  message: 'Refresh',
                  child: IconButton(
                    icon: const Icon(
                      Icons.refresh,
                      size: 16,
                    ),
                    onPressed: () {
                      stopSearching();
                      notifier.fetchAllKeys();
                    },
                  ),
                ),
              ],
            ),
          ),
          const Expanded(
            child: _StateMapper(),
          ),
        ],
      ),
    );
  }
}

class _StateMapper extends StatelessWidget {
  const _StateMapper();

  @override
  Widget build(BuildContext context) {
    return switch (SharedPreferencesStateNotifierProvider.of(context).value) {
      final AsyncStateData<SharedPreferencesState> value => _KeysList(
          keys: value.data.allKeys,
        ),
      final AsyncStateError<SharedPreferencesState> value => ErrorPanel(
          error: value.error,
          stackTrace: value.stackTrace,
        ),
      AsyncStateLoading<SharedPreferencesState>() => const Center(
          child: CircularProgressIndicator(),
        ),
    };
  }
}

class _KeysList extends StatefulWidget {
  const _KeysList({
    required this.keys,
  });

  final List<String> keys;

  @override
  State<_KeysList> createState() => _KeysListState();
}

class _KeysListState extends State<_KeysList> {
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: scrollController,
      child: ListView.builder(
        controller: scrollController,
        itemCount: widget.keys.length,
        itemBuilder: (BuildContext context, int index) => _KeyItem(
          keyName: widget.keys[index],
        ),
      ),
    );
  }
}

class _KeyItem extends StatelessWidget {
  const _KeyItem({
    required this.keyName,
  });

  final String keyName;

  @override
  Widget build(BuildContext context) {
    final SharedPreferencesStateNotifier notifier =
        SharedPreferencesStateNotifierProvider.of(context);
    final bool isSelected =
        notifier.value.dataOrNull?.selectedKey?.key == keyName;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final Color? backgroundColor =
        isSelected ? colorScheme.selectedRowBackgroundColor : null;

    return InkWell(
      onTap: () {
        notifier.selectKey(keyName);
      },
      child: Container(
        color: backgroundColor,
        padding: const EdgeInsets.only(
          left: defaultSpacing,
          right: densePadding,
          top: densePadding,
          bottom: densePadding,
        ),
        child: Text(
          keyName,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
    );
  }
}
